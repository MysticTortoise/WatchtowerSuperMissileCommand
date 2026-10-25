class AMiniSkullEnemy : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent Sprite;

    UPROPERTY(DefaultComponent)
    UMiniDamageable Damageable;
    default Damageable.Team = EMiniTeam::Enemies;

    UPROPERTY(EditAnywhere)
    float Speed;

    private AMiniBase TargetBase;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        PickNewTarget();

        Damageable.BindDefaultDamageable();
        Damageable.Damage.AddUFunction(this, n"OnHit");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(!HideGame::Mini::GameActive())
            return;

        if(TargetBase == nullptr || TargetBase.IsDead()){
            PickNewTarget();
        }

        if(TargetBase != nullptr){
            MoveToTarget(TargetBase.GetActorLocation());
        } else {
            MoveToTarget(GetActorLocation() + FVector::UpVector * 100);
        }

    }

    UFUNCTION()
    void MoveToTarget(FVector Target){
        if(!HideGame::Mini::GameActive())
            return;

        FVector Offset = Target - GetActorLocation();

        FVector Dir = Offset;
        Dir.Normalize();

        Dir *= Speed * Gameplay::WorldDeltaSeconds;
        
        FVector MoveOffset;

        if(Dir.Size() < Offset.Size()){
            MoveOffset = Dir;
        } else {
            MoveOffset = Offset;
        }

        AddActorWorldOffset(MoveOffset);
    }

    UFUNCTION()
    void OnHit(int DamageAmount){
        if(!HideGame::Mini::GameActive())
            return;

        HideGame::GetGMMain().MiniMGR.AddKill();

        DestroyActor();
    }

    UFUNCTION()
    void PickNewTarget(){
        TargetBase = SelectNewTarget();
    }

    UFUNCTION()
    AMiniBase SelectNewTarget() const {
        TArray<AMiniBase> Bases = HideGame::Mini::GetAliveBases();
        if(Bases.Num() == 0){
            return nullptr;
        }
        return Bases[Math::RandRange(0, Bases.Num() - 1)];
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(!HideGame::Mini::GameActive())
            return;

        UMiniDamageable OtherDamageable = OtherActor.GetComponentByClass(UMiniDamageable);
        if(OtherDamageable == nullptr){
            return;
        }
        OtherDamageable.TryDamage(Damageable.Team, 1);
    }
};