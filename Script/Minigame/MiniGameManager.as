class AMiniGameManager : AActor
{
    UPROPERTY(BlueprintReadOnly)
    bool bGameActive = false;

    UPROPERTY()
    AMiniPlayer PlayerPawn;

    UPROPERTY(EditAnywhere)
    int KillsNeeded;

    UPROPERTY(NotEditable)
    int Kills;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        PlayerPawn = Gameplay::GetActorOfClass(AMiniPlayer);
    }


    UFUNCTION()
    void ActivateGame(){
        bGameActive = true;
    }

    UFUNCTION()
    void DeactivateGame(){
        bGameActive = false;
    }

    UFUNCTION()
    void AddKill(){
        Kills++;
        if(Kills >= KillsNeeded){
            Gameplay::OpenLevel(n"MAP_YouWin");
        }
    }
};

