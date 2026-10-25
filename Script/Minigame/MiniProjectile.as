class AMiniProjectile : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(EditAnywhere)
    EMiniTeam Team;

    UPROPERTY(EditAnywhere)
    int Damage = 1;

    UPROPERTY(EditAnywhere)
    FVector Direction;

    UPROPERTY(EditAnywhere)
    float Speed;

    UPROPERTY(EditAnywhere)
    int Hits = 1;

    TSet<AActor> HitActors;

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(!HideGame::Mini::GameActive())
            return;

        if(HitActors.Contains(OtherActor)){
            return;
        }
        UMiniDamageable OtherDamageable = OtherActor.GetComponentByClass(UMiniDamageable);
        if(OtherDamageable == nullptr){
            return;
        }
        if(OtherDamageable.TryDamage(Team, Damage)){
            Hits--;
            if(Hits <= 0){
                DestroyActor();
                return;
            }
            HitActors.Add(OtherActor);
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(!HideGame::Mini::GameActive())
            return;
        
        FHitResult _;
        AddActorLocalOffset(Direction * Speed * DeltaSeconds, true, _, false);
    }
};