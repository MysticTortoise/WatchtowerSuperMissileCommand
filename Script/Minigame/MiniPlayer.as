class AMiniPlayer : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent BodySprite;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent CannonSprite;

    UPROPERTY(DefaultComponent, Attach = CannonSprite, AttachSocket = CannonSource)
    USceneComponent CannonBarrel;

    UPROPERTY(DefaultComponent)
    UMiniDamageable Damageable;
    default Damageable.Team = EMiniTeam::Player;

    UPROPERTY(EditAnywhere)
    TSubclassOf<AMiniProjectile> Projectile;

    UPROPERTY(EditAnywhere, Meta = (ClampMin = 0))
    int ClipSize;

    UPROPERTY(EditAnywhere, Meta = (ClampMin = 0))
    float ReloadTime;

    UPROPERTY(NotEditable)
    int Clip;
    private float ReloadTimer;


    UPROPERTY(EditAnywhere)
    float MoveSpeed;

    private int AimDir;
    private int MaxAimDir;

    private float XMove;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MaxAimDir = CannonSprite.Flipbook.NumFrames-1;
        AimDir = Math::IntegerDivisionTrunc(MaxAimDir, 2);
        
        Damageable.BindDefaultDamageable();

        Clip = ClipSize;
    }

    UFUNCTION(BlueprintProtected)
    void TurnCannonLeft(){
        AimDir--;
        if(AimDir < 0){
            AimDir = 0;
        }
    }

    UFUNCTION(BlueprintProtected)
    void TurnCannonRight(){
        AimDir++;
        if(AimDir > MaxAimDir){
            AimDir = MaxAimDir;
        }
    }

    UFUNCTION(BlueprintProtected)
    void InputXMove(float NewXMove){
        XMove = NewXMove;
    }

    UFUNCTION()
    void InputShoot(){
        Shoot();
    }

    UFUNCTION()
    void Reload(){
        if(!HideGame::Mini::GameActive())
            return;

        Clip = 0;
        ReloadTimer = 0;
    }

    UFUNCTION()
    void Shoot(){
        if(!HideGame::Mini::GameActive())
            return;

        if(Clip <= 0){
            return;
        }

        Clip--;

        AMiniProjectile NewProjectile = Cast<AMiniProjectile>(SpawnActor(Projectile, CannonBarrel.GetWorldLocation()));
        NewProjectile.Direction = CannonBarrel.GetUpVector();

        if(Clip <= 0){
            // Start reload
            Reload();
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(!HideGame::Mini::GameActive())
            return;

        BodySprite.PlayRate = Math::Abs(XMove) > 0.05 ? 1 : 0;
        CannonSprite.SetPlaybackPositionInFrames(AimDir, true);

        FVector Offset = GetActorForwardVector();
        Offset *= XMove * DeltaSeconds * MoveSpeed;

        FHitResult _;
        AddActorLocalOffset(Offset, true, _, false);

        if(IsReloading()){
            ReloadTimer += DeltaSeconds;
            if(ReloadTimer >= ReloadTime){
                Clip = ClipSize;
            }
        }
    }

    UFUNCTION()
    bool IsReloading() const {
        return Clip <= 0;
    }
};