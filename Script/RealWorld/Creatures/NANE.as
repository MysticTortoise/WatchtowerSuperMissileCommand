namespace NGBND::FC1{
    const FConsoleCommand NANEApproach("HG.NAApproach", n"HGNAApproach");

    const FConsoleCommand NANEKill("HG.NAKill", n"HGNAKill");
}

UFUNCTION()
void HGNAApproach(TArray<FString> arguments){
    Gameplay::GetActorOfClass(ANANE).BeginApproachingDoor();
}

UFUNCTION()
void HGNAKill(TArray<FString> arguments){
    Gameplay::GetActorOfClass(ANANE).KillPlayer();
}


class ANANE : AWalkingDoorCreature
{


    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {   
        Super::BeginPlay();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(bKillin)
            return;
        Super::Tick(DeltaSeconds);
        if(bWatching && Player.bIsHidden){
            KillPlayer();
        }
    }

    UFUNCTION(BlueprintOverride)
    void KillPlayer() {
        Super::KillPlayer();
        Gameplay::GetActorOfClass(AHark).AlarmKill();
    }
};