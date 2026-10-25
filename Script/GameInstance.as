class UHideGameInstance : UGameInstance
{
    UPROPERTY()
    UTexture2D GOTexture;
};

namespace HideGame{
    UFUNCTION(BlueprintPure)
    UHideGameInstance GetGI(){
        return Cast<UHideGameInstance>(Gameplay::GameInstance);
    }
}