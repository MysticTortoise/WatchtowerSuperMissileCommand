class ADoorCreature : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent BodyMesh;

    UPROPERTY(EditDefaultsOnly)
    TSubclassOf<UAnimInstance> AnimationBlueprint;

    protected ADoor HallwayDoor;


    UPROPERTY(EditDefaultsOnly)
    FLinearColor DebugColor;

    UPROPERTY(BlueprintReadOnly)
    protected ARealPlayer Player;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        HallwayDoor = Gameplay::GetActorOfClass(ADoor);
        Player = Gameplay::GetActorOfClass(ARealPlayer);
    }
};