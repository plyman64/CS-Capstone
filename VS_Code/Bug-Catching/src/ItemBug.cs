using Vintagestory.API.Client;
using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.Util;

namespace BugCatching
{
	// Token: 0x02000052 RID: 82
	public class ItemBug : Item
	{
		// Token: 0x060002C4 RID: 708 RVA: 0x00027640 File Offset: 0x00025840
		public override string GetHeldTpUseAnimation(ItemSlot activeHotbarSlot, Entity byEntity)
		{
			return null;
		}

		// Token: 0x060002C5 RID: 709 RVA: 0x00027654 File Offset: 0x00025854
		public override void OnHeldInteractStart(ItemSlot slot, EntityAgent byEntity, BlockSelection blockSel, EntitySelection entitySel, bool firstEvent, ref EnumHandHandling handHandling)
		{
			double posX, posY, posZ;
			

			if(byEntity.World.BlockAccessor.GetBlock(blockSel.Position).FirstCodePart() == "terrarium") {
				
				api.Logger.Debug("Looking at terrarium");

				posX = (double)((float)(blockSel.Position.X) + 0.5f);
				posY = (double)((float)(blockSel.Position.Y) + 0.1875f);
				posZ = (double)((float)(blockSel.Position.Z) + 0.5f);

			} else {
				posX = (double)((float)(blockSel.Position.X + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.X)) + 0.5f);
				posY = (double)(blockSel.Position.Y + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.Y));
				posZ = (double)((float)(blockSel.Position.Z + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.Z)) + 0.5f);
			}

			bool flag = byEntity.Controls.Sneak && blockSel != null;
			if (flag)
			{
				IPlayer player = byEntity.World.PlayerByUid((byEntity as EntityPlayer).PlayerUID);
				bool flag2 = !byEntity.World.Claims.TryAccess(player, blockSel.Position, EnumBlockAccessFlags.BuildOrBreak);
				if (!flag2)
				{
					bool flag3 = !(byEntity is EntityPlayer) || player.WorldData.CurrentGameMode != EnumGameMode.Creative;
					if (flag3)
					{
						slot.TakeOut(1);
						slot.MarkDirty();
					}
					AssetLocation assetLocation = new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0));
					EntityProperties entityType = byEntity.World.GetEntityType(assetLocation);
					bool flag4 = entityType == null;
					if (flag4)
					{
						byEntity.World.Logger.Error("ItemCreature: No such entity - {0}", new object[]
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
						Entity entity = byEntity.World.ClassRegistry.CreateEntity(entityType);
						bool flag6 = entity != null;
						if (flag6)
						{
							entity.ServerPos.X = posX;
							entity.ServerPos.Y = posY;
							entity.ServerPos.Z = posZ;
							entity.ServerPos.Yaw = (float)byEntity.World.Rand.NextDouble() * 2f * 3.1415927f;
							entity.Pos.SetFrom(entity.ServerPos);
							entity.PositionBeforeFalling.Set(entity.ServerPos.X, entity.ServerPos.Y, entity.ServerPos.Z);
							entity.Attributes.SetString("origin", "playerplaced");
							byEntity.World.SpawnEntity(entity);
							handHandling = EnumHandHandling.PreventDefaultAction;
						}
					}
				}
			}
			else
			{
				base.OnHeldInteractStart(slot, byEntity, blockSel, entitySel, firstEvent, ref handHandling);
			}
		}

		// Token: 0x060002C6 RID: 710 RVA: 0x000278F8 File Offset: 0x00025AF8
		public override WorldInteraction[] GetHeldInteractionHelp(ItemSlot inSlot)
		{
			return new WorldInteraction[]
			{
				new WorldInteraction
				{
					HotKeyCode = "sneak",
					ActionLangCode = "heldhelp-place",
					MouseButton = EnumMouseButton.Right
				}
			}.Append(base.GetHeldInteractionHelp(inSlot));
		}
	}
}