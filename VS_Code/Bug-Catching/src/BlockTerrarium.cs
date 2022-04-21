using Vintagestory.API.Util;
using Vintagestory.API.Client;
using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;

namespace BugCatching {

    public class BlockTerrarium : Block {

        public bool hasBugInside;

        public BlockTerrarium() {
            this.hasBugInside = false;
        }
        /*
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

                bool flag = bug.Controls.Sneak && blockSel != null;
                if (flag)
                {
                    //IPlayer player = bug.World.PlayerByUid((bug as EntityPlayer).PlayerUID);
                    bool flag2 = !bug.World.Claims.TryAccess(byPlayer, blockSel.Position, EnumBlockAccessFlags.BuildOrBreak);
                    if (!flag2)
                    {
                        bool flag3 = byPlayer.WorldData.CurrentGameMode != EnumGameMode.Creative;
                        if (flag3)
                        {
                            byPlayer.InventoryManager.ActiveHotbarSlot.TakeOut(1);
                            byPlayer.InventoryManager.ActiveHotbarSlot.MarkDirty();
                        }
                        AssetLocation assetLocation = new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0));
                        EntityProperties entityType = bug.World.GetEntityType(assetLocation);
                        bool flag4 = entityType == null;
                        if (flag4)
                        {
                            bug.World.Logger.Error("ItemCreature: No such entity - {0}", new object[]
                            {
                                assetLocation
                            });
                            bool flag5 = this.api.World.Side == EnumAppSide.Client;
                            if (flag5)
                            {
                                (this.api as ICoreClientAPI).TriggerIngameError(this, "nosuchentity", "No such entity '{0}' loaded.");
                            }
                        }
                        else
                        {
                            Entity entity = bug.World.ClassRegistry.CreateEntity(entityType);
                            bool flag6 = entity != null;
                            if (flag6)
                            {
                                entity.ServerPos.X = (double)((float)(blockSel.Position.X - 0.5f));
                                entity.ServerPos.Y = (double)(blockSel.Position.Y + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.Y));
                                entity.ServerPos.Z = (double)((float)(blockSel.Position.Z - 0.5f));
                                entity.ServerPos.Yaw = (float)bug.World.Rand.NextDouble() * 2f * 3.1415927f;
                                entity.Pos.SetFrom(entity.ServerPos);
                                entity.PositionBeforeFalling.Set(entity.ServerPos.X, entity.ServerPos.Y, entity.ServerPos.Z);
                                entity.Attributes.SetString("origin", "playerplaced");
                                bug.World.SpawnEntity(entity);
                                //handHandling = EnumHandHandling.PreventDefaultAction;
                            }
                        }
                    }
                }
            }

            return true;
        }
        */

    }
}