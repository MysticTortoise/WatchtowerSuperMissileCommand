namespace NGBND::FC1{
    const FConsoleCommand VoyeurApproach("HG.VYApproach", n"HGVYApproach");

    const FConsoleCommand VoyeurKill("HG.VYKill", n"HGVYKill");
}

UFUNCTION()
void HGVYApproach(TArray<FString> arguments){
    Gameplay::GetActorOfClass(AVoyeur).Spawn();
}

UFUNCTION()
void HGVYKill(TArray<FString> arguments){
    Gameplay::GetActorOfClass(AVoyeur).KillPlayer();
}


class AVoyeur : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent BodyMesh;

     UPROPERTY(EditDefaultsOnly)
    UAnimationAsset KillAnim;

    UPROPERTY(EditDefaultsOnly)
    UAnimationAsset KillAnimCamera;

    UPROPERTY(EditDefaultsOnly)
    UTexture2D KillTex;


    UPROPERTY(DefaultComponent)
    UAudioComponent DeathSound;
    default DeathSound.bAutoActivate = false;
    default DeathSound.bAllowSpatialization = false;

    protected bool bKillin;

    UPROPERTY(BlueprintReadOnly, NotEditable)
    protected ARealPlayer Player;

    UPROPERTY(NotEditable)
    bool bPresent;

    UPROPERTY(EditDefaultsOnly)
    FFloatRange AppearTime;

    UPROPERTY(EditDefaultsOnly)
    float KillTime;

    UPROPERTY(EditDefaultsOnly)
    float LeaveTime;

    private float Timer;
    private float LeaveTimer;


    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Player = Gameplay::GetActorOfClass(ARealPlayer);
        GoAway();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(bKillin)
            return;
        if(bPresent && Player.bHiding){
            LeaveTimer += DeltaSeconds;
            if(LeaveTimer >= LeaveTime){
                GoAway();
            }
            
            return;
        }

        Timer -= DeltaSeconds;

    
        if(Timer <= 0){
            if(bPresent){
                KillPlayer();
            } else {
                Spawn();
            }
        }
    }

    UFUNCTION()
    void GoAway(){
        Timer = MUtil::RandFromRange(AppearTime);
        bPresent = false;
    }


    UFUNCTION()
    void Spawn(){
        if(Gameplay::GetActorOfClass(ANANE).State != EWalkingDoorCreatureState::Away){
            GoAway();
            return;
        }

        Timer = KillTime;
        bPresent = true;
        LeaveTimer = 0;
    }



    UFUNCTION()
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

};