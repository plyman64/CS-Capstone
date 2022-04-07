using System;
using Vintagestory.API.Client;
using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.Datastructures;
using Vintagestory.API.Util;

namespace BugCatching
{
	// Token: 0x020003C2 RID: 962
	public class ItemBug : Item
	{
		// Token: 0x06001907 RID: 6407 RVA: 0x00004338 File Offset: 0x00002538
		public override string GetHeldTpUseAnimation(ItemSlot activeHotbarSlot, Entity byEntity)
		{
			return null;
		}

		// Token: 0x06001908 RID: 6408 RVA: 0x000DDD40 File Offset: 0x000DBF40
		public override void OnHeldInteractStart(ItemSlot slot, EntityAgent byEntity, BlockSelection blockSel, EntitySelection entitySel, bool firstEvent, ref EnumHandHandling handHandling)
		{
			if (blockSel == null)
			{
				return;
			}
			IPlayer player = byEntity.World.PlayerByUid((byEntity as EntityPlayer).PlayerUID);
			if (!byEntity.World.Claims.TryAccess(player, blockSel.Position, EnumBlockAccessFlags.BuildOrBreak))
			{
				return;
			}
			if (!(byEntity is EntityPlayer) || player.WorldData.CurrentGameMode != EnumGameMode.Creative)
			{
				slot.TakeOut(1);
				slot.MarkDirty();
			}
			AssetLocation assetLocation = new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0));
			EntityProperties entityType = byEntity.World.GetEntityType(assetLocation);
			if (entityType == null)
			{
				byEntity.World.Logger.Error("ItemBug: No such entity - {0}", new object[]
				{
					assetLocation
				});
				if (this.api.World.Side == EnumAppSide.Client)
				{
					(this.api as ICoreClientAPI).TriggerIngameError(this, "nosuchentity", string.Format("No such entity loaded - '{0}'.", assetLocation));
				}
				return;
			}
			Entity entity = byEntity.World.ClassRegistry.CreateEntity(entityType);
			if (entity != null)
			{
				entity.ServerPos.X = (double)((float)(blockSel.Position.X + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.X)) + 0.5f);
				entity.ServerPos.Y = (double)(blockSel.Position.Y + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.Y));
				entity.ServerPos.Z = (double)((float)(blockSel.Position.Z + (blockSel.DidOffset ? 0 : blockSel.Face.Normali.Z)) + 0.5f);
				entity.ServerPos.Yaw = (float)byEntity.World.Rand.NextDouble() * 2f * 3.1415927f;
				entity.Pos.SetFrom(entity.ServerPos);
				entity.PositionBeforeFalling.Set(entity.ServerPos.X, entity.ServerPos.Y, entity.ServerPos.Z);
				entity.Attributes.SetString("origin", "playerplaced");
				JsonObject attributes = this.Attributes;
				if (attributes != null && attributes.IsTrue("setGuardedEntityAttribute"))
				{
					entity.WatchedAttributes.SetLong("guardedEntityId", byEntity.EntityId);
					EntityPlayer entityPlayer = byEntity as EntityPlayer;
					if (entityPlayer != null)
					{
						entity.WatchedAttributes.SetString("guardedPlayerUid", entityPlayer.PlayerUID);
					}
				}
				byEntity.World.SpawnEntity(entity);
				handHandling = EnumHandHandling.PreventDefaultAction;
			}
		}

		// Token: 0x06001909 RID: 6409 RVA: 0x000DDFC0 File Offset: 0x000DC1C0
		public override string GetHeldTpIdleAnimation(ItemSlot activeHotbarSlot, Entity byEntity, EnumHand hand)
		{
			EntityProperties entityType = byEntity.World.GetEntityType(new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0)));
			if (entityType == null)
			{
				return base.GetHeldTpIdleAnimation(activeHotbarSlot, byEntity, hand);
			}
			if (Math.Max(entityType.CollisionBoxSize.X, entityType.CollisionBoxSize.Y) > 1f)
			{
				return "holdunderarm";
			}
			return "holdbothhands";
		}

		// Token: 0x0600190A RID: 6410 RVA: 0x0000A173 File Offset: 0x00008373
		public override WorldInteraction[] GetHeldInteractionHelp(ItemSlot inSlot)
		{
			return new WorldInteraction[]
			{
				new WorldInteraction
				{
					ActionLangCode = "heldhelp-place",
					MouseButton = EnumMouseButton.Right
				}
			}.Append(base.GetHeldInteractionHelp(inSlot));
		}
	}
}