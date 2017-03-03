package net.mobideck.appdeck.core;

import android.support.v4.util.ArrayMap;

public class ApiManager {

    private ArrayMap<String, ApiCommand> mApiCommands;

    ApiManager() {
        mApiCommands = new ArrayMap<>();
        initApiCommands();
    }

    public void initApiCommands() {

    }

    public void add(String command, ApiCommand apiCommand) {
        mApiCommands.put(command, apiCommand);
    }

    public boolean apiCall(ApiCall apiCall) {
        ApiCommand apiCommand = mApiCommands.get(apiCall.command);
        if (apiCommand != null) {
            return apiCommand.apiCall(apiCall);
        }
        return false;
    }

}
