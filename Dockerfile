FROM registry.redhat.io/ubi8/dotnet-70 AS dotnet-70 
#FROM quay.io/paulchapmanibm/ppc64le/dotnet-70 dotnet-70
WORKDIR /app
EXPOSE 8080
EXPOSE 443

FROM dotnet-70 AS build
WORKDIR /src
COPY --chown=1001 ["SignalRChat/SignalRChat.csproj", "SignalRChat/"]
RUN dotnet restore "SignalRChat/SignalRChat.csproj"
COPY --chown=1001 . ./
WORKDIR "/src/SignalRChat"
USER root
RUN dotnet build "SignalRChat.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SignalRChat.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM dotnet-70 AS final
WORKDIR /app
COPY --chown=1001 --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SignalRChat.dll"]
