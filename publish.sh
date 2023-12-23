#!/bin/bash

version="0.2.2"
fullName="dig"
names=("dig" "server")
src="src"
outputRoot="./publish"
framework="net8.0"

# If no runtimes are passed as arguments, use the default ones
if [ $# -eq 0 ]; then
    runTimes=("win-x64" "linux-x64" "osx-x64" "linux-arm64")
else
    runTimes=("$@")
fi

if [ -d "$outputRoot" ]; then
    rm -rf $outputRoot
fi

publish_project() {
    local name=$1
    local runtime=$2

    dotnet restore ./$src/$name/$name.csproj -r $runtime

    # fully standalone with embedded dotnet framework
    dotnet publish ./$src/$name/$name.csproj -c Release -r $runtime --no-restore --framework $framework --self-contained true /p:Version=$version /p:PublishReadyToRun=true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:IncludeNativeLibrariesForSelfExtract=True /p:StripSymbols=true /p:PublishDir="bin/Release/$framework/$runtime" --output $outputRoot/standalone/$runtime

    # single file without embedded dotnet framework
    dotnet publish ./$src/$name/$name.csproj -c Release -r $runtime --no-restore --framework $framework --self-contained false /p:Version=$version /p:PublishReadyToRun=true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:IncludeNativeLibrariesForSelfExtract=True /p:StripSymbols=true /p:PublishDir="bin/Release/$framework/$runtime" --output $outputRoot/singlefile/$runtime
}

for runTime in "${runTimes[@]}"; do
    for name in "${names[@]}"; do
        publish_project $name $runTime
    done
done