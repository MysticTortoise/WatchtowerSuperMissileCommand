class ADoor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent DoorMesh;

    UPROPERTY()
    ADoorCreature CurrentCreature;


    private bool bCreatureDoorOpen;

    UFUNCTION(BlueprintPure)
    bool IsClosed(){
        return !bCreatureDoorOpen;
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        //Print(f"{bCreatureDoorOpen}", 0);
    }


    UFUNCTION()
    void SetCurrentCreature(ADoorCreature Creature){
        CurrentCreature = Creature;
        DoorMesh.SetAnimInstanceClass(Creature.AnimationBlueprint);
        bCreatureDoorOpen = false;
    }

    UFUNCTION()
    void OpenDoor(){
        bCreatureDoorOpen = true;
    }

    UFUNCTION()
    void CloseDoor(){
        bCreatureDoorOpen = false;
    }


    UFUNCTION()
    void CreatureLeave(){
        CurrentCreature = nullptr;
    }


    UFUNCTION()
    bool IsDoorOccupied(){
        return CurrentCreature != nullptr;
    }
};