//! Durable voxel block store for RustMC.
//!
//! Provides place/break-equivalent **set** and **get** that survive reloading
//! the same on-disk world store. This is the bootstrap persistence boundary
//! for Minecraft-like block mutate; it does not depend on Veloren, Pumpkin,
//! or Leafish at link time.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs::{self, File};
use std::io::{BufReader, BufWriter};
use std::path::{Path, PathBuf};

/// Block identifier. `0` means air / empty.
pub type BlockId = u32;

/// Integer cell coordinate in world space.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct BlockPos {
    pub x: i32,
    pub y: i32,
    pub z: i32,
}

impl BlockPos {
    pub const fn new(x: i32, y: i32, z: i32) -> Self {
        Self { x, y, z }
    }
}

/// Errors from world-store open / mutate / persist.
#[derive(Debug, thiserror::Error)]
pub enum WorldError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("serialize/deserialize error: {0}")]
    Serde(#[from] serde_json::Error),
    #[error("invalid world store at {path}: {reason}")]
    InvalidStore { path: PathBuf, reason: String },
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct WorldFile {
    /// Schema version for future migrations.
    version: u32,
    /// Sparse map keyed as `"x,y,z"` → block id. Air (`0`) is omitted.
    blocks: BTreeMap<String, BlockId>,
}

impl WorldFile {
    fn key(pos: BlockPos) -> String {
        format!("{},{},{}", pos.x, pos.y, pos.z)
    }

    fn parse_key(key: &str) -> Option<BlockPos> {
        let mut parts = key.split(',');
        let x = parts.next()?.parse().ok()?;
        let y = parts.next()?.parse().ok()?;
        let z = parts.next()?.parse().ok()?;
        if parts.next().is_some() {
            return None;
        }
        Some(BlockPos::new(x, y, z))
    }
}

/// On-disk durable voxel world. Call [`Self::flush`] or drop via [`Self::save`]
/// after mutations; [`Self::open`] reloads from the same path.
pub struct WorldStore {
    path: PathBuf,
    data: WorldFile,
    dirty: bool,
}

impl WorldStore {
    const CURRENT_VERSION: u32 = 1;
    const STORE_FILE: &'static str = "blocks.json";

    /// Create a new empty world directory and store file.
    pub fn create(dir: impl AsRef<Path>) -> Result<Self, WorldError> {
        let dir = dir.as_ref();
        fs::create_dir_all(dir)?;
        let path = dir.join(Self::STORE_FILE);
        if path.exists() {
            return Err(WorldError::InvalidStore {
                path: path.clone(),
                reason: "store already exists; use open()".into(),
            });
        }
        let mut store = Self {
            path,
            data: WorldFile {
                version: Self::CURRENT_VERSION,
                blocks: BTreeMap::new(),
            },
            dirty: true,
        };
        store.save()?;
        Ok(store)
    }

    /// Open an existing world store from `dir/blocks.json`.
    pub fn open(dir: impl AsRef<Path>) -> Result<Self, WorldError> {
        let path = dir.as_ref().join(Self::STORE_FILE);
        let file = File::open(&path)?;
        let reader = BufReader::new(file);
        let data: WorldFile = serde_json::from_reader(reader)?;
        if data.version == 0 || data.version > Self::CURRENT_VERSION {
            return Err(WorldError::InvalidStore {
                path: path.clone(),
                reason: format!("unsupported version {}", data.version),
            });
        }
        for key in data.blocks.keys() {
            if WorldFile::parse_key(key).is_none() {
                return Err(WorldError::InvalidStore {
                    path: path.clone(),
                    reason: format!("invalid block key {key:?}"),
                });
            }
        }
        Ok(Self {
            path,
            data,
            dirty: false,
        })
    }

    /// Place or replace a block (Minecraft place equivalent). `0` clears the cell.
    pub fn set_block(&mut self, pos: BlockPos, id: BlockId) {
        let key = WorldFile::key(pos);
        if id == 0 {
            if self.data.blocks.remove(&key).is_some() {
                self.dirty = true;
            }
        } else {
            let prev = self.data.blocks.insert(key, id);
            if prev != Some(id) {
                self.dirty = true;
            }
        }
    }

    /// Break a block (set to air). Returns the previous id (0 if already air).
    pub fn break_block(&mut self, pos: BlockPos) -> BlockId {
        let prev = self.get_block(pos);
        self.set_block(pos, 0);
        prev
    }

    /// Read the block at `pos`. Missing cells are air (`0`).
    pub fn get_block(&self, pos: BlockPos) -> BlockId {
        self.data
            .blocks
            .get(&WorldFile::key(pos))
            .copied()
            .unwrap_or(0)
    }

    /// Persist dirty state to disk.
    pub fn save(&mut self) -> Result<(), WorldError> {
        if let Some(parent) = self.path.parent() {
            fs::create_dir_all(parent)?;
        }
        let file = File::create(&self.path)?;
        let writer = BufWriter::new(file);
        serde_json::to_writer_pretty(writer, &self.data)?;
        self.dirty = false;
        Ok(())
    }

    /// Flush if dirty.
    pub fn flush(&mut self) -> Result<(), WorldError> {
        if self.dirty {
            self.save()?;
        }
        Ok(())
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    pub fn is_dirty(&self) -> bool {
        self.dirty
    }

    pub fn occupied_count(&self) -> usize {
        self.data.blocks.len()
    }
}

impl Drop for WorldStore {
    fn drop(&mut self) {
        let _ = self.flush();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_world_dir(label: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time")
            .as_nanos();
        let dir = std::env::temp_dir().join(format!("rustmc-world-{label}-{nanos}"));
        let _ = fs::remove_dir_all(&dir);
        dir
    }

    #[test]
    fn set_get_round_trip_same_session() {
        let dir = temp_world_dir("same");
        let mut world = WorldStore::create(&dir).expect("create");
        let pos = BlockPos::new(3, 64, -7);
        assert_eq!(world.get_block(pos), 0);
        world.set_block(pos, 42);
        assert_eq!(world.get_block(pos), 42);
        world.break_block(pos);
        assert_eq!(world.get_block(pos), 0);
        world.set_block(pos, 7);
        world.flush().expect("flush");
        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn durable_set_survives_reload() {
        let dir = temp_world_dir("reload");
        let pos = BlockPos::new(1, 2, 3);
        let stone: BlockId = 1;
        let dirt: BlockId = 2;

        {
            let mut world = WorldStore::create(&dir).expect("create");
            world.set_block(pos, stone);
            world.set_block(BlockPos::new(0, 0, 0), dirt);
            world.save().expect("save");
            assert_eq!(world.get_block(pos), stone);
        }

        // Re-open the same store path — shipped API, not a re-implementation.
        let world = WorldStore::open(&dir).expect("open after save");
        assert_eq!(world.get_block(pos), stone);
        assert_eq!(world.get_block(BlockPos::new(0, 0, 0)), dirt);
        assert_eq!(world.get_block(BlockPos::new(9, 9, 9)), 0);
        assert_eq!(world.occupied_count(), 2);

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn break_then_reload_is_air() {
        let dir = temp_world_dir("break");
        let pos = BlockPos::new(-4, 10, 8);

        {
            let mut world = WorldStore::create(&dir).expect("create");
            world.set_block(pos, 99);
            world.save().expect("save");
        }
        {
            let mut world = WorldStore::open(&dir).expect("open");
            assert_eq!(world.break_block(pos), 99);
            world.save().expect("save after break");
        }
        let world = WorldStore::open(&dir).expect("reopen");
        assert_eq!(world.get_block(pos), 0);
        assert_eq!(world.occupied_count(), 0);

        let _ = fs::remove_dir_all(&dir);
    }
}
