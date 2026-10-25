namespace NGBND::FC1{
    const FConsoleCommand HarkApproach("HG.HKApproach", n"HGHKApproach");

    const FConsoleCommand HarkKill("HG.HKKill", n"HGHKKill");
}

UFUNCTION()
void HGHKApproach(TArray<FString> arguments){
    Gameplay::GetActorOfClass(AHark).BeginApproachingDoor();
}

UFUNCTION()
void HGHKKill(TArray<FString> arguments){
    Gameplay::GetActorOfClass(AHark).KillPlayer();
}


class AHark : AWalkingDoorCreature
{
    UPROPERTY(EditDefaultsOnly)
    UAnimationAsset AlarmAnim;

    





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
        if(bWatching && !Player.bIsHidden){
            KillPlayer();
        }
    }

    UFUNCTION()
    void AlarmKill(){
        bKillin = true;
        BodyMesh.PlayAnimation(AlarmAnim, false);
    }
};