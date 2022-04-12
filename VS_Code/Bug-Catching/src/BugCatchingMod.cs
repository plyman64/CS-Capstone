using Vintagestory.API.Client;
using Vintagestory.API.Common;
using Vintagestory.API.Server;

[assembly: ModInfo( "BugCatching",
	Description = "",
	Website     = "",
	Authors     = new []{ "pepaigea" } )]

namespace BugCatching
{
	public class BugCatchingMod : ModSystem
	{

		public override void Start(ICoreAPI api)
		{
			api.RegisterEntity("EntityBug", typeof(EntityBug));
			api.RegisterItemClass("ItemBug", typeof(ItemBug));
			api.RegisterBlockClass("BlockTerrarium", typeof(BlockTerrarium));
		}
		
		public override void StartClientSide(ICoreClientAPI api)
		{
			
		}
		
		public override void StartServerSide(ICoreServerAPI api)
		{
			
		}
	}
}
