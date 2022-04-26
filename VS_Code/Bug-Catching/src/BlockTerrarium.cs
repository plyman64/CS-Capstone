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

            bool holdingBug = (slot.Itemstack.Item.FirstCodePart() == "bug");

            if(holdingBug && !(this.hasMaxBugs())) {

                bool flag = byPlayer.Entity.Controls.Sneak && blockSel != null;

                //spawn the bug in the terrarium
                if (flag)
                {
                    IPlayer player = world.PlayerByUid((byPlayer as EntityPlayer).PlayerUID);
                    bool flag2 = !world.Claims.TryAccess(player, blockSel.Position, EnumBlockAccessFlags.BuildOrBreak);
                    if (!flag2)
                    {
                        bool flag3 = !(byPlayer is EntityPlayer) || player.WorldData.CurrentGameMode != EnumGameMode.Creative;
                        if (flag3)
                        {
                            slot.TakeOut(1);
                            slot.MarkDirty();
                        }
                        AssetLocation assetLocation = new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0));
                        EntityProperties entityType = world.GetEntityType(assetLocation);
                        bool flag4 = entityType == null;
                        if (flag4)
                        {
                            world.Logger.Error("ItemCreature: No such entity - {0}", new object[]
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
                            Entity entity = world.ClassRegistry.CreateEntity(entityType);
                            bool flag6 = entity != null;
                            if (flag6)
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
                                return true;
                            }
                        }
                    }
                }
            } else {
                //Red text: "Maximum number of bugs inside terrarium
                ICoreClientAPI coreClientAPI = api as ICoreClientAPI;
                if (coreClientAPI != null) {
                    coreClientAPI.TriggerIngameError(this, "terrariumFull", "Terrarium is full");
                }
            }
            return false;
        }
    }
}