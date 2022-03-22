using VintageStory.API.Common;
using VintageStory.API.Common.Entities;
using VintageStory.API.MathTools;
using VintageStory.GameContent;
using VintageStory.API.DataStructures;

namespace BugCatchingMod {

	public class BugCatching : ModSystem {
		public override void Start(ICoreAPI api) {
			base.Start(api);
			api.RegisterEntity("entitybeetle", typeof(EntityBeetle));
		}
	}

	public class EntityBeetle : EntityAgent {

		public EntityBeetle() {

		}
	
		public override void Initialize(EntityProperties properties, ICoreAPI api, long InChunkIndex3d) {
			base.initialize(properties, api, InChunkIndex3d);
		}

		public override void OnInteract(EntityAdent byEntity, Itemslot slot, Vec3d hitPosition, EnumInteractMode mode) {

			if(!this.Alive || this.World.Side == EnumAppSide.Client || mode == 0) {
				base.OnInteract(byEntity, slot, hitPosition, mode);
				return;
			} else {

				var stack = new ItemStack(byEntity.World.GetItem(new AssetLocation("mod:beetle")));

				if(!byEntity.TryGiveItemStack(stack)) {
					byEntity.World.SpawnItemEntity(stack, this.ServerPos.XYZ);
				}
				this.die();
				return;
			}
		}
	}
}