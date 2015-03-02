package be.shouldit.proxy.lib.utils;

import android.content.Context;

import be.shouldit.proxy.lib.WiFiApConfig;
import be.shouldit.proxy.lib.ProxyStatusItem;

public class ProxyUIUtils
{

    public static String GetStatusTitle(WiFiApConfig conf, Context callerContext)
    {
        String description;

        switch (conf.getCheckingStatus())
        {
            case CHECKED:
            {
                ProxyStatusItem status = conf.getStatus().getMostRelevantErrorProxyStatusItem();

                if (status != null)
                {
                    switch (status.statusCode)
                    {
                        case PROXY_ENABLED:
                            description = "status_title_not_enabled";
                            break;

                        case PROXY_VALID_HOSTNAME:
                            description = "status_title_invalid_host";
                            break;

                        case PROXY_VALID_PORT:
                            description = "status_title_invalid_port";
                            break;

                        case PROXY_REACHABLE:
                            description = "status_title_not_reachable";
                            break;

                        case WEB_REACHABLE:
                            description = "status_title_web_not_reachable";
                            break;

                        default:
                            description = "";
                    }
                }
                else
                    description = "status_title_enabled";
            }
            break;

            case CHECKING:
                description = "status_title_checking";
                break;

            default:
                description = "";
                break;
        }

        return description;
    }

    public static String GetStatusDescription(WiFiApConfig conf, Context callerContext)
    {
        String description;

        switch (conf.getCheckingStatus())
        {
            case CHECKED:
            {
                ProxyStatusItem status = conf.getStatus().getMostRelevantErrorProxyStatusItem();

                if (status != null)
                {
                    switch (status.statusCode)
                    {
                        case PROXY_ENABLED:
                            description = "status_description_not_enabled";
                            break;

                        case PROXY_VALID_HOSTNAME:
                            description = "status_description_invalid_host";
                            break;

                        case PROXY_VALID_PORT:
                            description = "status_description_invalid_port";
                            break;

                        case PROXY_REACHABLE:
                            description = "status_description_not_reachable";
                            break;
                        case WEB_REACHABLE:
                            description = "status_description_web_not_reachable";
                            break;

                        default:
                            description = "";
                    }
                }
                else
                {
                    description = "status_description_enabled";
                    description = description + " " + conf.toStatusString();
                    break;
                }

            }
            break;

            case CHECKING:
                description = "status_description_checking";
                break;

            default:
                description = "";
                break;
        }

        return description;
    }

    public static String ProxyConfigToStatusString(WiFiApConfig conf, Context callerContext)
    {
        String message = String.format("%s", conf.toStatusString());

        message += " - " + GetStatusTitle(conf, callerContext);

        return message;
    }
}
