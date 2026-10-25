namespace MUtil{
    float RandFromRange(FFloatRange Range){
        return Math::RandRange(Range.LowerBound.Value, Range.UpperBound.Value);
    }
}