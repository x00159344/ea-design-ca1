#!/usr/bin/env python3

# {"filename":"aname.png", "plottype":"line", "x":["1", "2", "3", "4", "5"], "y":["10", "8", "6", "15", "22", "0", "10", "8", "6", "15"], "ylab":["first line", "second line"]}


def eades_msvcs_make_graph(rqst):

    import io
    import matplotlib.pyplot as plt
    import numpy as np
    from google.cloud import storage
    from urllib import request

    bucket_name = 'x00159344_eades_ca1'
    
    request_json = rqst.get_json()
    if request_json:
        if 'filename' in request_json:
            if 'plottype' in request_json:
                if 'x' in request_json and 'y' in request_json:
                    x = request_json['x']
                    y = np.array(request_json['y']).astype(np.float)

                    if request_json['plottype'] == 'bar':
                        if len(x) == len(y):
                            positions = range(len(x))
                            plt.xticks(positions, x)
                            plt.bar(positions, y)
                            if 'ylab' in request_json:
                                if type(request_json['ylab']) is str:
                                    plt.ylabel(request_json['ylab'])
                                else:
                                    return f'ERROR: Y label is not a string'
                        else:
                            return f'ERROR: X and Y data not the same length'

                    elif request_json['plottype'] == 'line':
                        xlen = len(x)
                        ylen = len(y)
                        if xlen != 0 and ylen != 0:
                            if ylen % xlen == 0:
                                numLines = ylen/xlen
                                ylab = None
                                if 'ylab' in request_json:
                                    ylab = request_json['ylab']
                                    if numLines == 1:
                                        if type(ylab) is str:
                                            ylab = [ ylab ]
                                        elif not type(ylab) is list:
                                            return f'ERROR: Y label is not a string or a list'
                                    elif not type(ylab) is list:
                                        return f'ERROR: Y label is not a list'
                                        
                                ynp = np.array(y)
                                if ylab != None:
                                    for i in range(ylen//xlen):
                                        plt.plot(x, ynp[i*xlen:(i+1)*xlen], label=ylab[i])
                                    plt.legend()
                                else:
                                    plt.plot(x, ynp[i*xlen:(i+1)*xlen])
                            else:
                                return f'ERROR: Length of X or Y data is 0'
                        else:
                            return f'ERROR: Length of Y data is not a multiple of the length of X data'

                    else:
                        return f'ERROR: Unknown plot type'
                        
                    buf = io.BytesIO()
                    plt.savefig(buf, format='png')
                    
                    storageClient = storage.Client()
                    bucket = storageClient.get_bucket(bucket_name) 
                    blob = bucket.blob(request_json['filename'])
                    
                    if not blob.exists():
                        blob.upload_from_string(buf.getvalue(), content_type='image/png')
                        retVal = "gs://" + bucket_name + "/" + blob.name 
                    else:
                        return f'ERROR: File exists'
                        
                    buf.close()
                    return retVal

                else:
                    return f'ERROR: X or Y or both data not specified'
            else:
                return f'ERROR: Plot type not specified'
        else:
            return f'ERROR: File name not specified'
    else:
        return f'ERROR: Data not specified'

