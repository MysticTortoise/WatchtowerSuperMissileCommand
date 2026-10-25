class ARealPlayer : APawn
{
    // ============ GEN COMPS ============
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent PlayerSkel;

    UPROPERTY(DefaultComponent, Attach = PlayerSkel, AttachSocket = "CameraSocket")
    USceneComponent CameraBase;

    UPROPERTY(DefaultComponent, Attach = CameraBase)
    UCameraComponent Camera;

    UPROPERTY(DefaultComponent)
    UAudioComponent HideSound;
    default HideSound.bAutoActivate = false;
    default HideSound.bAllowSpatialization = false;

    UPROPERTY(DefaultComponent)
    UAudioComponent UnhideSound;
    default UnhideSound.bAutoActivate = false;
    default UnhideSound.bAllowSpatialization = false;
    
    // ============ MINI SYSTEM ============
    
    UPROPERTY(DefaultComponent, Attach = PlayerSkel, AttachSocket = "GameSocket")
    UStaticMeshComponent GameSystemMesh;

    UPROPERTY(EditDefaultsOnly, Meta=(ClampMin = 0))
    int GameScreenMatIndex = 1;

    UPROPERTY(DefaultComponent)
    UWidgetComponent Widget;
    default Widget.bRenderInMainPass = false;


    UPROPERTY(EditDefaultsOnly, BlueprintProtected)
    UMaterialInterface ScreenOffMat;
    private UMaterialInstanceDynamic ScreenOnMat;

    // ============ CONFS ============
    UPROPERTY()
    float LookSensitivity;

    // ============ STATE ============
    UPROPERTY(BlueprintReadOnly, NotEditable)
    bool bHiding;

    UPROPERTY(BlueprintReadOnly, NotEditable)
    bool bIsHidden;

    UPROPERTY(BlueprintReadOnly, NotEditable)
    bool bIsGameUp;

    UPROPERTY(BlueprintReadOnly, NotEditable)
    FVector2D FreeLookRotation;

    UPROPERTY(BlueprintReadOnly, EditDefaultsOnly)
    float FreeLookTransitionSpeed;

    private float FreeLookAlpha;

    UPROPERTY()
    protected bool bScreenOn;

    UPROPERTY(BlueprintReadOnly, NotEditable)
    bool bIsDying;

    // ============ FUNCS ============

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        UpdateUIScreen();

        Gameplay::GetPlayerController(0).bShowMouseCursor = false;
    }

    UFUNCTION()
    void UpdateUIScreen(){
        if(Widget.RenderTarget == nullptr){
            System::SetTimerForNextTick(this, "UpdateUIScreen");
            return;
        }

        ScreenOnMat = Material::CreateDynamicMaterialInstance(
            GameSystemMesh.GetMaterial(GameScreenMatIndex), 
            n"MDI_GameSystemScreen"
            );

        ScreenOnMat.SetTextureParameterValue(n"Color Texture", Widget.RenderTarget);
        GameDown();
        UnHide();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(bIsDying){
            Camera.SetRelativeRotation(
                MUtil::LerpDeltaQuat(Camera.GetRelativeRotation().Quaternion(), FQuat(), 30, DeltaSeconds)
            );
            return;
        }

        FreeLookAlpha = Math::Clamp(
            FreeLookAlpha + (DeltaSeconds / FreeLookTransitionSpeed) * (IsFreeLooking() ? 1 : -1),
            0,1
        );

        FQuat LookRot = FQuat::MakeFromEuler(FVector(0, FreeLookRotation.Y, FreeLookRotation.X));
        Camera.SetRelativeRotation(FQuat::FastLerp(
                FQuat(), 
                LookRot, 
                FreeLookAlpha));
    }


    UFUNCTION(BlueprintEvent)
    void Hide(){
        bHiding = true;
        System::SetTimer(this, n"FinishedHiding", 1, false);
        HideSound.Play();
        GameDown();
    }

    UFUNCTION()
    void FinishedHiding(){
        bIsHidden = true;
    }

    UFUNCTION(BlueprintEvent)
    void UnHide(){
        System::ClearTimer(this, "FinishedHiding");
        bHiding = false;
        UnhideSound.Play();
        GameUp();
        bIsHidden = false;
    }

    UFUNCTION(BlueprintEvent)
    void GameUp(){
        bIsGameUp = true;
    }

    UFUNCTION(BlueprintEvent)
    void GameDoneUp(){
        bScreenOn = true;
        GameSystemMesh.SetMaterial(GameScreenMatIndex, ScreenOnMat);
        if(HideGame::GetGMMain() != nullptr)
            HideGame::GetGMMain().MiniMGR.ActivateGame();
    }

    UFUNCTION(BlueprintEvent)
    void GameDown(){
        bIsGameUp = false;
        GameSystemMesh.SetMaterial(GameScreenMatIndex, ScreenOffMat);
        HideGame::GetGMMain().MiniMGR.DeactivateGame();
        bScreenOn = false;
    }

    UFUNCTION()
    void EnterFreeLook(){
        if(!bScreenOn)
            return;
        
        GameDown();
        FreeLookRotation = FVector2D::ZeroVector;
    }

    UFUNCTION()
    void ToggleGameUpDown(){
        if(bHiding)
            return;

        if(bIsGameUp)
            EnterFreeLook();
        else
            GameUp();
    }

    UFUNCTION()
    void FreeLook(FVector2D LookVec){
        if(!IsFreeLooking())
            return;

        FreeLookRotation += LookVec * LookSensitivity;
    }

    UFUNCTION()
    bool IsFreeLooking() const {
        return !bHiding && !bIsGameUp;
    }


    UFUNCTION(BlueprintEvent)
    void KillPlayer(UAnimationAsset CameraAnimation){
        PlayerSkel.PlayAnimation(CameraAnimation, false);
        DisableInput(Gameplay::GetPlayerController(0));
        bIsDying = true;
    }

};