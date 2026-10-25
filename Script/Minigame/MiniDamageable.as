delegate bool MiniIsDamageableByEvent(EMiniTeam Team);
event void MiniDamageEvent(int Damage);

class UMiniDamageable : UActorComponent
{
    UPROPERTY()
    MiniIsDamageableByEvent IsDamageableBy();

    UPROPERTY()
    MiniDamageEvent Damage();


    UPROPERTY(EditAnywhere)
    EMiniTeam Team;

    UFUNCTION()
    bool DefaultIsDamageableBy(EMiniTeam IncomingTeam){
        if(!HideGame::Mini::GameActive())
            return false;
        if(IncomingTeam == EMiniTeam::Neutral || Team == EMiniTeam::Neutral)
            return true;
        return Team != IncomingTeam;
    }

    void BindDefaultDamageable(){
        IsDamageableBy.BindUFunction(this, n"DefaultIsDamageableBy");
    }


    UFUNCTION()
    bool TryDamage(EMiniTeam IncomingTeam, int DamageAmount){
        if(HideGame::Mini::GameActive() && IsDamageableBy.Execute(IncomingTeam)){
            Damage.Broadcast(DamageAmount);
            return true;
        }
        return false;
    }
};