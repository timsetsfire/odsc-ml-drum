module Custom
using MLJ, DataFrames
using Base.Filesystem

# export load_model, mypipeline, mypipe
export load_model, transform, mypipe, score
# mypipeline = @pipeline FeatureSelector Standardizer EvoTreeRegressor name=mypipe
@info "creating pipeline type"
DecisionTreeRegressor = @load DecisionTreeRegressor pkg="DecisionTree"
@pipeline FeatureSelector Standardizer DecisionTreeRegressor name=mypipe

function load_model(code_dir)
    @info "loading tree pipeline"
    artifact_path = Filesystem.joinpath(code_dir, "tree_pipeline.jlso")
    model = machine(artifact_path)
    return model
end

function transform(data, model) 
    data = coerce(data, :Chas => Count)
    data = coerce(data, :Rad => Count)
    data = coerce(data, :Tax => Count)
    return data
end

function score(data, model; kwargs)
    predictions = predict(model, data)
    return DataFrame(Predictions = predictions)
end

end