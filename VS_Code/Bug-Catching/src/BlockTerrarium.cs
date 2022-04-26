using Vintagestory.API.Client;
using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;

namespace BugCatching {

    public class BlockTerrarium : Block {

        public int numBugsInside, maxBugs;

        public BlockTerrarium() {
            numBugsInside = 0;
            maxBugs = 3;
        }

        public bool hasMaxBugs() {
            return (numBugsInside == maxBugs);
        }

        public override bool OnBlockInteractStart(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel)
        {
            ItemSlot slot = byPlayer.InventoryManager.ActiveHotbarSlot;
            api.Logger.Debug("Made it past ItemSlot");

            Item item = slot.Itemstack.Item;
            api.Logger.Debug("Made it past Item");

            api.Logger.Debug("Slot empty? " + slot.Empty);
            api.Logger.Debug("item firstCodePart: " + item.FirstCodePart());

            if(slot.Empty || item.FirstCodePart() != "bug") {
                api.Logger.Debug("Returning false");
                return false;
            }

            if(!(hasMaxBugs())) {
                api.Logger.Debug("Made it past first if");

                bool flag = byPlayer.Entity.Controls.Sneak && blockSel != null;
                api.Logger.Debug("Made it past flag");

                //spawn the bug in the terrarium
                if (flag)
                {
                    //IPlayer player = world.PlayerByUid((byPlayer as EntityPlayer).PlayerUID);
                    api.Logger.Debug("Made it past IPlayer");

                    bool flag2 = !world.Claims.TryAccess(byPlayer, blockSel.Position, EnumBlockAccessFlags.BuildOrBreak);
                    api.Logger.Debug("Made it past flag2");

                    if (!flag2)
                    {
                        AssetLocation assetLocation = new AssetLocation(slot.Itemstack.Item.Code.Domain, slot.Itemstack.Item.CodeEndWithoutParts(0));
                        api.Logger.Debug("Made it past AssetLocation: " + assetLocation.ToString());
                        EntityProperties entityType = world.GetEntityType(assetLocation);
                        api.Logger.Debug("Made it past EntityProperties");
                        bool flag3 = entityType == null;
                        if (flag3)
                        {
                            api.Logger.Debug("Made it past flag4 and 4th if");
                            world.Logger.Error("ItemCreature: No such entity - {0}", new object[]
                            {
                                assetLocation
                            });
                            bool flag4 = this.api.World.Side == EnumAppSide.Client;
                            api.Logger.Debug("Made it past flag5");
                            if (flag4)
                            {
                                (this.api as ICoreClientAPI).TriggerIngameError(this, "nosuchentity", "No such entity '{0}' loaded.");
                            }
                        }
                        else
                        {
                            Entity entity = world.ClassRegistry.CreateEntity(entityType);
                            api.Logger.Debug("Made it past CreateEntity()");
                            bool flag5 = entity != null;
                            if (flag5)
                            {
                                entity.ServerPos.X = (double)((float)(blockSel.Position.X) + 0.5f);
                                entity.ServerPos.Y = (double)((float)(blockSel.Position.Y) + 0.1875f);
                                entity.ServerPos.Z = (double)((float)(blockSel.Position.Z) + 0.5f);
                                entity.ServerPos.Yaw = (float)world.Rand.NextDouble() * 2f * 3.1415927f;
                                entity.Pos.SetFrom(entity.ServerPos);
                                entity.PositionBeforeFalling.Set(entity.ServerPos.X, entity.ServerPos.Y, entity.ServerPos.Z);
                                entity.Attributes.SetString("origin", "playerplaced");
                                world.SpawnEntity(entity);
                                //byPlayer.handHandling = EnumHandHandling.PreventDefaultAction;
                                api.Logger.Debug("Made it past SpawnEntity");

                                bool flag6 = !(byPlayer is EntityPlayer) || byPlayer.WorldData.CurrentGameMode != EnumGameMode.Creative;
                                api.Logger.Debug("Made it past flag3");

                                if (flag6)
                                {
                                    slot.TakeOut(1);
                                    slot.MarkDirty();
                                    api.Logger.Debug("Made it past takeOut() and markDirty()");
                                }
                                return true;
                            }
                        }
                    }
                }
            } else {
                //Red text: "Maximum number of bugs inside terrarium
                //ICoreClientAPI coreClientAPI = this.api as ICoreClientAPI;
                //if (coreClientAPI != null) {
                //    coreClientAPI.TriggerIngameError(this, "terrariumFull", "Terrarium is full");
                //}
            }
            return false;
        }
    }
}