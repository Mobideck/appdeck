package com.mobideck.appdeck;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Vector;

import org.apache.http.Header;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.BinaryHttpResponseHandler;

import android.util.Log;

import SevenZip.HRESULT;
import SevenZip.MyRandomAccessFile;
import SevenZip.Archive.IArchiveExtractCallback;
import SevenZip.Archive.IInArchive;
import SevenZip.Archive.SevenZipEntry;
import SevenZip.Archive.SevenZip.Handler;

public class RemoteAppCache {

	static String TAG = "RemoteAppCache";
	
	String url;
	int ttl;
	String outputPath;
	byte[] _data;
	
	RemoteAppCache(String url, int ttl)
	{
		this.url = url;
		this.ttl = ttl;
		outputPath = AppDeck.getInstance().cacheDir + "/httpcache/";
	}
	
	public void downloadAppCache()
	{

		AsyncHttpClient client = new AsyncHttpClient();
		client.get(url, new BinaryHttpResponseHandler(new String[] { ".*" /*"application/x-7z-compressed"*/}) {
				
		     @Override
		     public void onSuccess(byte[] data) {
		         // Successfully got a response
		    	 Log.d(TAG,"URL Downloaded: " + url);
		    	 _data = data;
		    	 new Thread(new Runnable() {
		    	        public void run() {
		   		    	 try {
		 					RemoteAppCacheRandomAccessMemory istream = new RemoteAppCacheRandomAccessMemory(_data);
		 					extractAppCache(istream, outputPath);
		 				} catch (IOException e) {
		 					// TODO Auto-generated catch block
		 					e.printStackTrace();
		 				}
		    	        }
		    	    }).start();
		     }
		     
		     @Override
		    public void onFinish() {
		    	// TODO Auto-generated method stub
		    	super.onFinish();
		    }
		     
		     @Override
		    public void onStart() {
		    	// TODO Auto-generated method stub
		    	super.onStart();
		    }

			@Override
			public void onFailure(int statusCode, Header[] headers, byte[] binaryData,
					Throwable error) {
				// TODO Auto-generated method stub
				Log.d(TAG,"Failed to download: " + url);
				super.onFailure(statusCode, headers, binaryData, error);
			}
		     
		 });	
	}
	
	public void extractAppCache(SevenZip.IInStream istream, String outputPath) throws IOException
	{
		// create outputPath if needed
		File folder = new File(outputPath);
		boolean success = true;
        if(!folder.exists()){
            success = folder.mkdirs();
        }
        if (!success){ 
            Log.d(TAG,"Folder not created.");
        }
        else{
            Log.d(TAG,"Folder created!");
        }		
		
		
		//RemoteAppCacheRandomAccessFile istream = new RemoteAppCacheRandomAccessFile(inputFile,"r");
        
        IInArchive archive = new Handler();
        
        int ret = archive.Open( istream );
        
        if (ret != 0) {
            System.out.println("ERROR !");
            return ;
        }
        
        //Vector<String> listOfNames = new Vector<String>();		
		
    	RemoteAppCacheArchiveExtractCallback extractCallbackSpec = new RemoteAppCacheArchiveExtractCallback(outputPath);
        IArchiveExtractCallback extractCallback = extractCallbackSpec;
        extractCallbackSpec.Init(archive);
        extractCallbackSpec.PasswordIsDefined = false;
        
        try {  
            int len = 0;
            int arrays []  = null;
            
           /* if (listOfNames.size() >= 1) {
                arrays = new int[listOfNames.size()];
                for(int i = 0 ; i < archive.size() ; i++) {
                    if (listOfNames.contains(archive.getEntry(i).getName())) {
                        arrays[len++] = i;
                    }
                }
            }*/
                
            int res;
            
            //if (len == 0) {
                res = archive.Extract(null, -1, IInArchive.NExtract_NAskMode_kExtract , extractCallback);
            //} else {
            //    res = archive.Extract(arrays, len, mode, extractCallback);
            //}
            
            if (res == HRESULT.S_OK) {
                if (extractCallbackSpec.NumErrors == 0)
                    System.out.println("Ok Done");
                else
                    System.out.println(" " + extractCallbackSpec.NumErrors + " errors");
            } else {
                System.out.println("ERROR !!");
            }
        } catch (java.io.IOException e) {
            System.out.println("IO error : " + e.getLocalizedMessage());
        }
        
        archive.close();
    }


    public class RemoteAppCacheArchiveExtractCallback implements IArchiveExtractCallback // , ICryptoGetTextPassword,
    {
        
        class OutputStream extends java.io.OutputStream {
            java.io.RandomAccessFile file;
            
            public OutputStream(java.io.RandomAccessFile f) {
                file = f;
            }
            
            public void close()  throws java.io.IOException {
                file.close();
                file = null;
            }
            /*
            public void flush()  throws java.io.IOException {
                file.flush();
            }
             */
            public void write(byte[] b)  throws java.io.IOException {
                file.write(b);
            }
            
            public void write(byte[] b, int off, int len)  throws java.io.IOException {
                file.write(b,off,len);
            }
            
            public void write(int b)  throws java.io.IOException {
                file.write(b);
            }
        }
        
        public int SetTotal(long size) {
            return HRESULT.S_OK;
        }
        
        public int SetCompleted(long completeValue) {
            return HRESULT.S_OK;
        }
        
        public void PrintString(String str) {
            System.out.print(str);
        }
        
        public void PrintNewLine() {
            System.out.println("");
        }
        public int PrepareOperation(int askExtractMode) {
            _extractMode = false;
            switch (askExtractMode) {
                case IInArchive.NExtract_NAskMode_kExtract:
                    _extractMode = true;
            };
            switch (askExtractMode) {
                case IInArchive.NExtract_NAskMode_kExtract:
                    PrintString("Extracting  ");
                    break;
                case IInArchive.NExtract_NAskMode_kTest:
                    PrintString("Testing     ");
                    break;
                case IInArchive.NExtract_NAskMode_kSkip:
                    PrintString("Skipping    ");
                    break;
            };
            PrintString(_filePath);
            return HRESULT.S_OK;
        }
        
        public int SetOperationResult(int operationResult) throws java.io.IOException {
            switch(operationResult) {
                case IInArchive.NExtract_NOperationResult_kOK:
                    break;
                default:
                {
                    NumErrors++;
                    PrintString("     ");
                    switch(operationResult) {
                        case IInArchive.NExtract_NOperationResult_kUnSupportedMethod:
                            PrintString("Unsupported Method");
                            break;
                        case IInArchive.NExtract_NOperationResult_kCRCError:
                            PrintString("CRC Failed");
                            break;
                        case IInArchive.NExtract_NOperationResult_kDataError:
                            PrintString("Data Error");
                            break;
                        default:
                            PrintString("Unknown Error");
                    }
                }
            }
                /*
                if(_outFileStream != null && _processedFileInfo.UTCLastWriteTimeIsDefined)
                    _outFileStreamSpec->File.SetLastWriteTime(&_processedFileInfo.UTCLastWriteTime);
                 */
            if (_outFileStream != null) _outFileStream.close(); // _outFileStream.Release();
                /*
                if (_extractMode && _processedFileInfo.AttributesAreDefined)
                    NFile::NDirectory::MySetFileAttributes(_diskFilePath, _processedFileInfo.Attributes);
                 */
            PrintNewLine();
            return HRESULT.S_OK;
        }
        
        java.io.OutputStream _outFileStream;
        
        public int GetStream(int index,
                java.io.OutputStream [] outStream,
                int askExtractMode) throws java.io.IOException {
            
            outStream[0] = null;
            
            SevenZipEntry item = _archiveHandler.getEntry(index);
            _filePath = item.getName();
            
            _filePath = _outputPath + "/" + _filePath;
            
            File file = new File(_filePath);
            
            switch (askExtractMode) {
                case IInArchive.NExtract_NAskMode_kTest:
                    return HRESULT.S_OK;
                    
                case IInArchive.NExtract_NAskMode_kExtract:
                    
                    try {
                        isDirectory = item.isDirectory();
                        
                        if (isDirectory) {
                            if (file.isDirectory()) {
                                return HRESULT.S_OK;
                            }
                            if (file.mkdirs())
                                return HRESULT.S_OK;
                            else
                                return HRESULT.S_FALSE;
                        }
                        
                        
                        File dirs = file.getParentFile();
                        if (dirs != null) {
                            if (!dirs.isDirectory())
                                if (!dirs.mkdirs())
                                    return HRESULT.S_FALSE;
                        }
                        
                        long pos = item.getPosition();
                        if (pos == -1) {
                            file.delete();
                        }
                        
                        java.io.RandomAccessFile outStr = new java.io.RandomAccessFile(_filePath,"rw");
                        
                        if (pos != -1) {
                            outStr.seek(pos);
                        }
                        
                        outStream[0] = new OutputStream(outStr);
                    } catch (java.io.IOException e) {
                        return HRESULT.S_FALSE;
                    }
                    
                    return HRESULT.S_OK;
                    
            }
            
            // other case : skip ...
            
            return HRESULT.S_OK;
            
        }
        
        SevenZip.Archive.IInArchive _archiveHandler;  // IInArchive
        String _filePath;       // name inside arcvhive
        String _diskFilePath;   // full path to file on disk
        String _outputPath; // path where file should be extract
        
        public long NumErrors;
        boolean PasswordIsDefined;
        String Password;
        boolean _extractMode;
        
        boolean isDirectory;
        
        public RemoteAppCacheArchiveExtractCallback(String outputPath)
        {
        	PasswordIsDefined = false;
        	_outputPath = outputPath;
        }
        
        
        public void Init(SevenZip.Archive.IInArchive archiveHandler) {
            NumErrors = 0;
            _archiveHandler = archiveHandler;
        }
        
    }

    public  class RemoteAppCacheRandomAccessFile extends SevenZip.IInStream  {
        
        java.io.RandomAccessFile _file;
        
        RemoteAppCacheRandomAccessFile(String filename,String mode)  throws java.io.IOException {
            _file  = new java.io.RandomAccessFile(filename,mode);
        }
        
        public long Seek(long offset, int seekOrigin)  throws java.io.IOException {
            if (seekOrigin == STREAM_SEEK_SET) {
                _file.seek(offset);
            }
            else if (seekOrigin == STREAM_SEEK_CUR) {
                _file.seek(offset + _file.getFilePointer());
            }
            return _file.getFilePointer();
        }
        
        public int read() throws java.io.IOException {
            return _file.read();
        }
     
        public int read(byte [] data, int off, int size) throws java.io.IOException {
            return _file.read(data,off,size);
        }
            
        public int read(byte [] data, int size) throws java.io.IOException {
            return _file.read(data,0,size);
        }
        
        public void close() throws java.io.IOException {
            _file.close();
            _file = null;
        }   
    }
    
    public  class RemoteAppCacheRandomAccessMemory extends SevenZip.IInStream  {
        
    	ByteArrayInputStream _stream;
    	
        //java.io.RandomAccessFile _file;
        
    	RemoteAppCacheRandomAccessMemory(byte[] data)  throws java.io.IOException {
        	if (data != null)
        		data = new byte[0];
       		_stream = new ByteArrayInputStream(data);
        }
        
        public long Seek(long offset, int seekOrigin)  throws java.io.IOException {
            if (seekOrigin == STREAM_SEEK_SET) {            	
            	_stream.reset();
            	return _stream.skip(offset);
            	//return offset;
            }
            else if (seekOrigin == STREAM_SEEK_CUR) {
            	return _stream.skip(offset);
                //_file.seek(offset + _stream.getFilePointer());
            }
            return 0; 
//            return _file.getFilePointer();
        }
        
        public int read() throws java.io.IOException {
            return _stream.read();
        }
     
        public int read(byte [] data, int off, int size) throws java.io.IOException {
            return _stream.read(data,off,size);
        }
            
        public int read(byte [] data, int size) throws java.io.IOException {
            return _stream.read(data,0,size);
        }
        
        public void close() throws java.io.IOException {
        	_stream.close();
        	_stream = null;
        }   
    }    
    
}
