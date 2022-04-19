using Vintagestory.API.Common;

namespace BugCatching {

    public class BlockTerrarium : Block {

        public bool hasBugInside;

        public BlockTerrarium() {
            this.hasBugInside = false;
        }
        public override bool OnBlockInteractStart(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel) {


            //If there is already a bug in the terrarium, do nothing
            if(hasBugInside) {
                api.Logger.Debug("Bug already in terrarium!");
                return false;
            }

            ItemStack currentItemStack = new ItemStack();
            currentItemStack = byPlayer.InventoryManager.ActiveHotbarSlot.Itemstack;

            bool holdingBug = (currentItemStack.Item.FirstCodePart() == "bug");

            //If the player is holding a bug, spawn that bug inside the terrarium
            if(holdingBug) {
                api.Logger.Debug("Spawning bug in terrarium!");

                EntityBug bug = new EntityBug();
                world.SpawnEntity(bug);
                //bug.TeleportTo(blockSel.Position);

                hasBugInside = true;

                //Remove one bug from the active slot
                byPlayer.InventoryManager.ActiveHotbarSlot.TakeOut(1);
            }

            return true;
        }

    }
}