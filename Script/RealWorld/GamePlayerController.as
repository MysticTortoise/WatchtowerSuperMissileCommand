class AGamePlayerController : APlayerController
{
    UPROPERTY(NotEditable)
    ARealPlayer RealPlayer;

    UPROPERTY(NotEditable)
    AMiniPlayer MiniPlayer;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        RealPlayer = Gameplay::GetActorOfClass(ARealPlayer);
        MiniPlayer = Gameplay::GetActorOfClass(AMiniPlayer);

        //SetViewTargetWithBlend(RealPlayer);

        Possess(RealPlayer);
    }

    void GameDown(){
        if(!RealPlayer.bIsGameUp)
            return;
        RealPlayer.GameDown();
    }

    void Hide(){
        RealPlayer.Hide();
    }
};