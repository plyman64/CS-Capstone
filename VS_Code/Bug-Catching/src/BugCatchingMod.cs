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
			api.RegisterEntity("EntityBeetle", typeof(EntityBeetle));
		}
		
		public override void StartClientSide(ICoreClientAPI api)
		{
			
		}
		
		public override void StartServerSide(ICoreServerAPI api)
		{
			
		}
	}
}
