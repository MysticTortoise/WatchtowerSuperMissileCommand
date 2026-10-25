class AMiniEnemySpawner : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UBoxComponent SpawnArea;

    UPROPERTY(EditAnywhere)
    TSubclassOf<AActor> TypeToSpawn;


    UPROPERTY(EditAnywhere)
    float SpawnInterval;

    UPROPERTY(EditAnywhere)
    bool bSpawningActive = true;

    private float SpawnTimer = 0;

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(!HideGame::Mini::GameActive()){
            return;
        }

        SpawnTimer += DeltaSeconds;
        if(SpawnTimer > SpawnInterval){
            SpawnTimed();
        }
    }

    UFUNCTION()
    void SpawnTimed(){
        SpawnTimer = 0;
        SpawnInstant();
    }


    UFUNCTION()
    void SpawnInstant(){
        //Print("Spawn Skele");
        FVector Spot = Math::RandomPointInBoundingBox(SpawnArea.GetWorldLocation(), SpawnArea.GetScaledBoxExtent());
        AActor NewActor = SpawnActor(TypeToSpawn, Spot);
    }
};