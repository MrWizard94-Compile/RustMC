//! RustMC **Veloren fork** adaptation surface.
//!
//! Upstream Veloren remains under `vendor/veloren` (engine reference). This crate is the
//! forked product API for Minecraft-like **block place** and **break** that persist across
//! world reload — the mutate boundary family play and tests use, without linking the full
//! GPL engine into every binary.
//!
//! Persistence is provided by composing the shipped [`rustmc_world::WorldStore`] so tests
//! drive this fork API end-to-end (not a re-implemented oracle).

use rustmc_world::{BlockId, BlockPos, WorldError, WorldStore};
use std::path::Path;

/// Errors from the Veloren-fork world surface.
#[derive(Debug, thiserror::Error)]
pub enum ForkError {
    #[error(transparent)]
    World(#[from] WorldError),
}

/// Forked voxel world: Minecraft-like place/break with durable reload.
pub struct VelorenForkWorld {
    store: WorldStore,
}

impl VelorenForkWorld {
    /// Create a new empty forked world directory.
    pub fn create(dir: impl AsRef<Path>) -> Result<Self, ForkError> {
        Ok(Self {
            store: WorldStore::create(dir)?,
        })
    }

    /// Open an existing forked world (same store path after reload).
    pub fn open(dir: impl AsRef<Path>) -> Result<Self, ForkError> {
        Ok(Self {
            store: WorldStore::open(dir)?,
        })
    }

    /// Place a block (Minecraft place). `id == 0` clears the cell.
    pub fn place_block(&mut self, pos: BlockPos, id: BlockId) {
        self.store.set_block(pos, id);
    }

    /// Break a block (Minecraft break). Returns previous id (`0` if air).
    pub fn break_block(&mut self, pos: BlockPos) -> BlockId {
        self.store.break_block(pos)
    }

    /// Query block at `pos` (`0` = air).
    pub fn get_block(&self, pos: BlockPos) -> BlockId {
        self.store.get_block(pos)
    }

    /// Persist dirty state.
    pub fn save(&mut self) -> Result<(), ForkError> {
        self.store.save()?;
        Ok(())
    }

    pub fn flush(&mut self) -> Result<(), ForkError> {
        self.store.flush()?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_dir(label: &str) -> std::path::PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time")
            .as_nanos();
        let dir = std::env::temp_dir().join(format!("rustmc-veloren-fork-{label}-{nanos}"));
        let _ = fs::remove_dir_all(&dir);
        dir
    }

    #[test]
    fn place_get_survives_reopen() {
        let dir = temp_dir("place");
        let pos = BlockPos::new(8, 64, -3);
        let stone: BlockId = 1;

        {
            let mut world = VelorenForkWorld::create(&dir).expect("create");
            assert_eq!(world.get_block(pos), 0);
            world.place_block(pos, stone);
            assert_eq!(world.get_block(pos), stone);
            world.save().expect("save");
        }

        let world = VelorenForkWorld::open(&dir).expect("reopen");
        assert_eq!(world.get_block(pos), stone);

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn break_then_reopen_is_air() {
        let dir = temp_dir("break");
        let pos = BlockPos::new(0, 12, 0);

        {
            let mut world = VelorenForkWorld::create(&dir).expect("create");
            world.place_block(pos, 99);
            world.save().expect("save");
        }
        {
            let mut world = VelorenForkWorld::open(&dir).expect("open");
            assert_eq!(world.break_block(pos), 99);
            world.save().expect("save");
        }

        let world = VelorenForkWorld::open(&dir).expect("reopen");
        assert_eq!(world.get_block(pos), 0);

        let _ = fs::remove_dir_all(&dir);
    }
}
