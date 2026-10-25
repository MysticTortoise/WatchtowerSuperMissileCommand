class AMainGameGM : AGameModeBase
{
    UPROPERTY()
    AMiniGameManager MiniMGR;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MiniMGR = Gameplay::GetActorOfClass(AMiniGameManager);
        if(MiniMGR == nullptr){
            MiniMGR = SpawnActor(AMiniGameManager);
        }
    }
};

namespace HideGame{
    UFUNCTION(BlueprintPure)
    AMainGameGM GetGMMain(){
        return Cast<AMainGameGM>(Gameplay::GetGameMode());
    }

    namespace Mini{
        bool GameActive(){
            return GetGMMain().MiniMGR.bGameActive;
        }
    }
}