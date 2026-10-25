class AMiniBase : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent Sprite;

    UPROPERTY(DefaultComponent)
    UBoxComponent HurtCollider;

    UPROPERTY(EditDefaultsOnly)
    UPaperFlipbook DeadAnim;

    UPROPERTY(DefaultComponent)
    UMiniDamageable Damageable;
    default Damageable.Team = EMiniTeam::Player;

    private bool bDead = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Damageable.BindDefaultDamageable();
        Damageable.Damage.AddUFunction(this, n"OnDamage");
    }

    UFUNCTION()
    void OnDamage(int _){
        DestroyBase();
    }

    UFUNCTION(BlueprintEvent)
    void DestroyBase(){
        if(bDead || !HideGame::Mini::GameActive()){
            return;
        }
        bDead = true;
        Sprite.Flipbook = DeadAnim;
    }

    UFUNCTION(BlueprintPure)
    bool IsDead() const {
        return bDead;
    }
};

namespace HideGame::Mini{
    UFUNCTION()
    TArray<AMiniBase> GetAliveBases(){
        TArray<AActor> Actors;
        Gameplay::GetAllActorsOfClass(AMiniBase, Actors);
        if(Actors.Num() == 0){
            return TArray<AMiniBase>();
        }
        TArray<AMiniBase> Bases;

        for(AActor Actor : Actors){
            AMiniBase Base = Cast<AMiniBase>(Actor);
            if(Base.IsDead())
                continue;
            Bases.Add(Base);
        }

        return Bases;
    }
}