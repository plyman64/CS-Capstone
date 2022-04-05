using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;

namespace BugCatching {

	public class EntityBeetle : EntityAgent {

		public static string NAME { get; } = "Beetle";

		Vintagestory.API.Common.Entities.EntityProperties properties = new Vintagestory.API.Common.Entities.EntityProperties();

		public EntityBeetle() {

		}
	
		public override void Initialize(EntityProperties properties, ICoreAPI api, long InChunkIndex3d) {
			base.Initialize(properties, api, InChunkIndex3d);
		}

		public override void OnInteract(EntityAgent byEntity, ItemSlot slot, Vec3d hitPosition, EnumInteractMode mode) {
			
			if(!this.Alive || this.World.Side == EnumAppSide.Client || mode == EnumInteractMode.Attack) {
				base.OnInteract(byEntity, slot, hitPosition, mode);
				return;
			} else {

				ItemStack stack = new ItemStack(byEntity.World.GetItem(new AssetLocation("bugcatching:beetle" + this.Code)), 1);

				if(!byEntity.TryGiveItemStack(stack)) {
					byEntity.World.SpawnItemEntity(stack, this.ServerPos.XYZ, null);
				}
				this.Die(EnumDespawnReason.Death, null);
				return;
				
			}
			
		}
	}
}