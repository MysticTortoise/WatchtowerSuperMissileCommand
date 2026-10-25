UENUM()
enum EWalkingDoorCreatureState{
    Away,
    Approaching,
    Opening,
    Leaving
}


class AWalkingDoorCreature : ADoorCreature
{

    UPROPERTY(DefaultComponent)
    UAudioComponent ApproachSound;

    UPROPERTY(EditDefaultsOnly)
    FFloatRange AppearTimer;

    UPROPERTY(NotEditable)
    float MoveTimer;


    UPROPERTY(EditDefaultsOnly)
    float ApproachTime;
    UPROPERTY(EditDefaultsOnly)
    float WaitAtDoorTime;
    UPROPERTY(EditDefaultsOnly)
    float LeaveTime;

    UPROPERTY(NotEditable)
    EWalkingDoorCreatureState State = EWalkingDoorCreatureState::Away;

    UPROPERTY(DefaultComponent)
    UAudioComponent EnterSound;

    UPROPERTY(DefaultComponent)
    UAudioComponent LeaveSound;

    UPROPERTY(DefaultComponent)
    UAudioComponent DeathSound;
    default DeathSound.bAutoActivate = false;
    default DeathSound.bAllowSpatialization = false;

    UPROPERTY(EditDefaultsOnly)
    UTexture2D KillTex;

    UPROPERTY(EditDefaultsOnly)
    UAnimationAsset KillAnim;

    UPROPERTY(EditDefaultsOnly)
    UAnimationAsset KillAnimCamera;

    UPROPERTY()
    bool bWatching;

    protected bool bKillin;
    

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
        ResetToAway();
    }


    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveTimer -= DeltaSeconds;

        //Print(f"{State} | {MoveTimer}", 0, DebugColor);

        if(MoveTimer <= 0){
            switch(State){
                case EWalkingDoorCreatureState::Away:
                    if(HallwayDoor.IsDoorOccupied()){
                        ResetToAway();
                    } else {
                        BeginApproachingDoor();
                    }
                    break;
                case EWalkingDoorCreatureState::Approaching:
                    OpenDoor();
                    break;
                case EWalkingDoorCreatureState::Opening:
                    LeaveDoor();
                    break;
                case EWalkingDoorCreatureState::Leaving:
                    FullyLeave();
                    break;
            }
        }

        
    }

    UFUNCTION(BlueprintEvent)
    void KillPlayer(){
        DeathSound.Play();
        bKillin = true;
        BodyMesh.PlayAnimation(KillAnim, false);
        Player.KillPlayer(KillAnimCamera);

        HideGame::GetGI().GOTexture = KillTex;

        System::SetTimer(this, n"ToMenu", KillAnim.GetPlayLength(), false);
    }

    UFUNCTION()
    void ToMenu(){
        Gameplay::OpenLevel(n"MAP_GameOver");
    }


    UFUNCTION()
    void ResetToAway(){
        State = EWalkingDoorCreatureState::Away;
        MoveTimer = MUtil::RandFromRange(AppearTimer);
    }

    UFUNCTION()
    void BeginApproachingDoor(){
        HallwayDoor.SetCurrentCreature(this);
        MoveTimer = ApproachTime;
        State = EWalkingDoorCreatureState::Approaching;
        ApproachSound.Play();
    }

    UFUNCTION()
    void OpenDoor(){
        EnterSound.Play();
        HallwayDoor.OpenDoor();
        MoveTimer = WaitAtDoorTime;
        State = EWalkingDoorCreatureState::Opening;
    }

    UFUNCTION()
    void LeaveDoor(){
        HallwayDoor.CloseDoor();
        MoveTimer = LeaveTime;
        State = EWalkingDoorCreatureState::Leaving;
        LeaveSound.Play();
    }

    UFUNCTION()
    void FullyLeave(){
        HallwayDoor.CreatureLeave();
        ResetToAway();
    }
};