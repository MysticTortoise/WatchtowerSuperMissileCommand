namespace MUtil{

    float LerpDeltaFactor(float lambda, float dt){
        return 1 - Math::Exp(-lambda * dt);
    }

    float LerpDelta(float a, float b, float lambda, float dt)
    {
        return Math::Lerp(a, b, LerpDeltaFactor(lambda, dt));
    }

    FQuat LerpDeltaQuat(FQuat a, FQuat b, float lambda, float dt){
        return FQuat::FastLerp(a, b, LerpDeltaFactor(lambda, dt));
    }
}