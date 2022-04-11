using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;

namespace BugCatching {

	public class EntityBug : EntityAgent {

		public static string NAME { get; } = "Bug";

		Vintagestory.API.Common.Entities.EntityProperties properties = new Vintagestory.API.Common.Entities.EntityProperties();

		public EntityBug() {

		}
	
		public override void Initialize(EntityProperties properties, ICoreAPI api, long InChunkIndex3d) {
			base.Initialize(properties, api, InChunkIndex3d);
		}

		public override void OnInteract(EntityAgent byEntity, ItemSlot slot, Vec3d hitPosition, EnumInteractMode mode) {
			
			if(!this.Alive || this.World.Side == EnumAppSide.Client || mode == EnumInteractMode.Attack) {
				base.OnInteract(byEntity, slot, hitPosition, mode);
				return;
			} else {

				//base.World.Logger.Error("Not able to pick up bug", new object [1]);

				ItemStack stack = new ItemStack(byEntity.World.GetItem(new AssetLocation(this.Code.Domain, base.CodeEndWithoutParts(0))));

				if(!byEntity.TryGiveItemStack(stack)) {
					byEntity.World.SpawnItemEntity(stack, this.ServerPos.XYZ, null);
				}
				this.Die(EnumDespawnReason.Death, null);
				return;
				
			}
			
		}
	}
}