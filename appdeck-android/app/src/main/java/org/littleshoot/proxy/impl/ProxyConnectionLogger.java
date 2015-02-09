package org.littleshoot.proxy.impl;

import android.util.Log;

/*import org.slf4j.LoggerFactory;
import org.slf4j.helpers.MessageFormatter;
import org.slf4j.spi.LocationAwareLogger;*/

/**
 * <p>
 * A helper class that logs messages for ProxyConnections. All it does is make
 * sure that the Channel and current state are always included in the log
 * messages (if available).
 * </p>
 * 
 * <p>
 * Note that this depends on us using a LocationAwareLogger so that we can
 * report the line numbers of the caller rather than this helper class.
 * </p>
 */
class ProxyConnectionLogger {
	
	public static String TAG = "ProxyConnectionLogger";
	
    private final ProxyConnection connection;
    //private final LocationAwareLogger logger;
    private final String fqcn = this.getClass().getCanonicalName();

    public ProxyConnectionLogger(ProxyConnection connection) {
        this.connection = connection;
      //  this.logger = (LocationAwareLogger) LoggerFactory.getLogger(connection
       //         .getClass());
    }

    protected void error(String message, Object... params) {
    	Log.e(TAG, fullMessage(message));
        /*if (logger.isErrorEnabled()) {
            doLog(LocationAwareLogger.ERROR_INT, message, params, null);
        }*/
    }

    protected void error(String message, Throwable t) {
    	Log.e(TAG, fullMessage(message));
        /*if (logger.isErrorEnabled()) {
            doLog(LocationAwareLogger.ERROR_INT, message, null, t);
        }*/
    }

    protected void warn(String message, Object... params) {
    	Log.w(TAG, fullMessage(message));
        /*if (logger.isWarnEnabled()) {
            doLog(LocationAwareLogger.WARN_INT, message, params, null);
        }*/
    }

    protected void warn(String message, Throwable t) {
    	Log.w(TAG, fullMessage(message));
        /*if (logger.isWarnEnabled()) {
            doLog(LocationAwareLogger.WARN_INT, message, null, t);
        }*/
    }

    protected void info(String message, Object... params) {
    	Log.i(TAG, fullMessage(message));
        /*if (logger.isInfoEnabled()) {
            doLog(LocationAwareLogger.INFO_INT, message, params, null);
        }*/
    }

    protected void info(String message, Throwable t) {
    	Log.i(TAG, fullMessage(message));
        /*if (logger.isInfoEnabled()) {
            doLog(LocationAwareLogger.INFO_INT, message, null, t);
        }*/
    }

    protected void debug(String message, Object... params) {
    	Log.d(TAG, fullMessage(message));
        /*if (logger.isDebugEnabled()) {
            doLog(LocationAwareLogger.DEBUG_INT, message, params, null);
        }*/
    }

    protected void debug(String message, Throwable t) {
    	Log.d(TAG, fullMessage(message));
        /*if (logger.isDebugEnabled()) {
            doLog(LocationAwareLogger.DEBUG_INT, message, null, t);
        }*/
    }

    protected void log(int level, String message, Object... params) {
    	Log.d(TAG, fullMessage(message));
        /*if (level != LocationAwareLogger.DEBUG_INT || logger.isDebugEnabled()) {
            doLog(level, message, params, null);
        }*/
    }
    
    protected void log(int level, String message, Throwable t) {
    	Log.d(TAG, fullMessage(message));
        /*if (level != LocationAwareLogger.DEBUG_INT || logger.isDebugEnabled()) {
            doLog(level, message, null, t);
        }*/
    }
    /*
    private void doLog(int level, String message, Object[] params, Throwable t) {
        String formattedMessage = fullMessage(message);
        if (params != null && params.length > 0) {
            formattedMessage = MessageFormatter.arrayFormat(formattedMessage,
                    params).getMessage();
        }
        logger.log(null, fqcn, level, formattedMessage, null, t);
        Log.i(TAG, formattedMessage);
    }*/

    private String fullMessage(String message) {
        String stateMessage = connection.getCurrentState().toString();
        if (connection.isTunneling()) {
            stateMessage += " {tunneling}";
        }
        String messagePrefix = "(" + stateMessage + ")";
        if (connection.channel != null) {
            messagePrefix = messagePrefix + " " + connection.channel;
        }
        return messagePrefix + ": " + message;
    }
}