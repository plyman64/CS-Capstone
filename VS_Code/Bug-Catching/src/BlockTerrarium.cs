using Vintagestory.API.Common;

namespace BugCatching {

    public class BlockTerrarium : Block {

        public bool hasBugInside;

        public BlockTerrarium() {
            this.hasBugInside = false;
        }
        public override bool OnBlockInteractStart(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel, ref EnumHandling handling) {

            ItemSlot activeHotbarSlot = new ItemSlot();
            activeHotbarSlot = byPlayer.InventoryManager.ActiveHotbarSlot;

            //If there is already a bug in the terrarium
            if(!hasBugInside) {
                api.Logger.Debug("Bug already in terrarium!");
                return false;
            }

            ItemStack currentItemStack = new ItemStack();
            currentItemStack = activeHotbarSlot.Itemstack;

            api.Logger.Debug("currentItemStack.Item.FirstCodePart: " + currentItemStack.Item.FirstCodePart());
            bool holdingBug = (currentItemStack.Item.FirstCodePart() == "beetle");

            if(holdingBug) {
                api.Logger.Debug("Spawning bug in terrarium!");

                EntityBug bug = new EntityBug();
                bug.TeleportTo(blockSel.Position);

                hasBugInside = true;

                activeHotbarSlot.TakeOut(1);
            }

            base.OnBlockInteractStop(secondsUsed, world, byPlayer, blockSel);

            return true;
        }

    }
}