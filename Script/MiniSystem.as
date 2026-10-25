class AMiniSystem : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UStaticMeshComponent GameSystemMesh;

    UPROPERTY(EditDefaultsOnly, Meta=(ClampMin = 0))
    int GameScreenMatIndex = 1;

    UPROPERTY(DefaultComponent)
    UWidgetComponent Widget;
    default Widget.bRenderInMainPass = false;

    UPROPERTY(EditDefaultsOnly, BlueprintProtected)
    UMaterialInterface ScreenOffMat;
    private UMaterialInstanceDynamic ScreenOnMat;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        UpdateUIScreen();
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
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        
    }


    UFUNCTION()
    void TurnOn(){
        GameSystemMesh.SetMaterial(GameScreenMatIndex, ScreenOnMat);
        HideGame::GetGMMain().MiniMGR.ActivateGame();
    }

    UFUNCTION()
    void TurnOff(){
        GameSystemMesh.SetMaterial(GameScreenMatIndex, ScreenOffMat);
        HideGame::GetGMMain().MiniMGR.DeactivateGame();
    }
};