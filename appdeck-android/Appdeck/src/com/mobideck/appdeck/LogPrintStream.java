package com.mobideck.appdeck;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import android.util.Log;

/**
 * A log stream that supports println, printf, and company. This class stands in
 * for System.out and System.err, but pushes each line of the output to
 * Android's logging facilities.
 */
public class LogPrintStream extends PrintStream {
  /**
   * Creates a new stream with the specified tag and priority.
   * 
   * @param tag
   * User-defined tag for log messages sent to this stream.
   * @param priority
   * Level of log messages sent to this stream.
   */
  public LogPrintStream(String tag, int priority) {
    super(new LogByteArrayOutputStream(tag, priority));
  }
}

/**
 * The class LogPrintStream is really just a wrapper. Messages sent to it get
 * dropped into this class's byte array. When a newline is sent, we issue a log
 * message for the array's contents up until the newline.
 */
class LogByteArrayOutputStream extends ByteArrayOutputStream {
  /** Tag for log messages */
  private String tag;

  /** Priority level for log messages */
  private int priority;

  /**
   * Creates a new stream with the specified tag and priority.
   * 
   * @param tag
   * User-defined tag for log messages sent to this stream.
   * @param priority
   * Level of log messages sent to this stream.
   */
  public LogByteArrayOutputStream(String tag, int priority) {
    this.tag = tag;
    this.priority = priority;
  }

  @Override
  public void write(int b) {
    // If we got a newline, let's issue out the buffer as it stands as a log
    // message. Otherwise, queue up the byte for a future log message.
    if (b == '\n') {
      emit();
    } else {
      super.write(b);
    }
  }

  @Override
  public void write(byte[] b, int offset, int length) {
    int start = offset;

    // Walk through the array, looking for newlines. If we hit one, commit
    // what we've seen so far in the passed array and emit the buffer as a
    // log message.
    for (int i = offset; i < offset + length; ++i) {
      if (b[i] == '\n') {
        super.write(b, start, i - start);
        emit();
        start = i + 1;
      }
    }

    // If the array didn't end with a newline, there'll be some bytes left
    // over. Let's just queue them up and wait for the next newline.
    if (start < offset + length) {
      super.write(b, start, offset + length - start);
    }
  }

  /**
   * Flush the byte array out to a log message and clear the buffer.
   */
  private void emit() {
    //Log.println(priority, tag, toString());
    String line = toString();
    Log.i(tag, line);
    
    reset();
  }
}
