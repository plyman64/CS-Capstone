using Vintagestory.API.Common;

namespace BugCatching {

    public class BlockTerrarium : Block {

        public bool hasBugInside;

        public BlockTerrarium() {
            this.hasBugInside = false;
        }
        public virtual bool OnBlockInteractStart(float secondsUsed, IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel) {

            //If there is already a bug in the terrarium
            if(!hasBugInside) {
                api.Logger.Debug("Bug already in terrarium!");
                return false;
            }

            ItemStack currentItemStack = new ItemStack();
            currentItemStack = byPlayer.InventoryManager.ActiveHotbarSlot.Itemstack;

            api.Logger.Debug("currentItemStack.Item.FirstCodePart: " + currentItemStack.Item.FirstCodePart());
            bool holdingBug = (currentItemStack.Item.FirstCodePart() == "beetle");

            if(holdingBug) {
                api.Logger.Debug("Spawning bug in terrarium!");

                EntityBug bug = new EntityBug();
                bug.TeleportTo(blockSel.Position);

                hasBugInside = true;

                currentItemStack.StackSize--;
            }

            base.OnBlockInteractStop(secondsUsed, world, byPlayer, blockSel);

            return true;
        }

    }
}