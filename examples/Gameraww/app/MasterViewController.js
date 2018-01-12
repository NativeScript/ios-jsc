import fetch from './fetch';

var dateFormatter = new NSDateFormatter();
dateFormatter.locale = NSLocale.currentLocale;
//dateFormatter.dateStyle = NSDateFormatterStyle.NSDateFormatterShortStyle;
//dateFormatter.timeStyle = NSDateFormatterStyle.NSDateFormatterShortStyle;
dateFormatter.doesRelativeDateFormatting = true;

function onTap() {
    var privTagData = NSString.stringWithString("de.ecsec.sign.private")
    .dataUsingEncoding(NSUTF8StringEncoding);
    var params = NSMutableDictionary.new();
    params.setValueForKey(kSecAttrKeyTypeECSECPrimeRandom, kSecAttrKeyType);
    params.setValueForKey(NSNumber.numberWithInt(256), kSecAttrKeySizeInBits);
    var privAttrs = NSMutableDictionary.new();
    // Uncommenting this line breaks the key generation with error -50 (errParamInvalid)
    //privAttrs.setValueForKey(kCFBooleanTrue, kSecAttrIsPermanent);
    privAttrs.setValueForKey(privTagData, kSecAttrApplicationTag);
    params.setObjectForKey(privAttrs, kSecPrivateKeyAttrs);
    // Playground warns me with: 'Untyped function calls may not accept type arguments.', when using the const error, but in WebStorm it does not bring this error.
    //const error = new interop.Reference<NSError>();
    var secKey = SecKeyCreateRandomKey(params, null /*error*/);
    if (secKey === null) {
        console.log("No key returned: " /*, error.value*/);
    }
    else {
        var nsstring = NSString.stringWithString("test");
        // Calls the native C malloc function. You must call free when finished using it.
        var buffer = malloc(4 * interop.sizeof(interop.types.unichar));
        nsstring.getCharacters(buffer); // Fill the buffer
        // Reinterpret the void* buffer as unichar*. The reference variable doesn't retain the allocated buffer.
        var reference = new interop.Reference(interop.types.unichar, buffer);
        console.log("Key returned: ", secKey);
        console.log("kSecPaddingPKCS1SHA256", kSecPaddingPKCS1SHA256);
        var hashBytesSize = 32;
        console.log("hashBytesSize", hashBytesSize);
        var hashBytes = malloc(hashBytesSize);
        console.log("hashBytes", hashBytes);
        var signedHashBytesSize = SecKeyGetBlockSize(secKey);
        console.log("signedHashBytesSize", signedHashBytesSize);
        var signedHashBytes = malloc(signedHashBytesSize);
        var bitesRef = new interop.Reference(interop.types.int64, signedHashBytes);
        console.log("signedHashBytes", signedHashBytes);
        var result = SecKeyRawSign(secKey, kSecPaddingPKCS1SHA256, "test", hashBytesSize, signedHashBytes, reference);
        //console.log(result, "<---- RESULT");
        //OSStatus SecKeyRawSign(SecKeyRef key, SecPadding padding, const uint8_t *dataToSign, size_t dataToSignLen, uint8_t *sig, size_t *sigLen);
        // var data = SecKeyRawSign(secKey, padding: SecPadding, dataToSign: string, dataToSignLen: number, sig: string, sigLen: interop.Pointer | interop.Reference<number>);
        CFRelease(secKey);
    }
    console.log("------------------------");
}

var JSMasterViewController = UITableViewController.extend(
    {
      viewDidLoad : function() {
        UITableViewController.prototype.viewDidLoad.call(this);

        this.items = [];

        this.refreshControl = new UIRefreshControl();
        this.refreshControl.addTargetActionForControlEvents(
            this, "loadData", UIControlEvents.ValueChanged);
        this.refreshControl.beginRefreshing();

        this.loadData();
      },
      "aboutPressed:" : function(sender) {
//        var alertWindow = new UIAlertView({
//          title : "About",
//          message : "NativeScript Team",
//          delegate : null,
//          cancelButtonTitle : "OK",
//          otherButtonTitles : null
//        });
//        alertWindow.show();
                                                          onTap();
      },
      numberOfSectionsInTableView : function(tableView) { return 1; },
      tableViewNumberOfRowsInSection : function(tableView, section) {
        return this.items.length;
      },
      prepareForSegueSender : function(segue, sender) {
        if (segue.identifier == "showDetail") {
          var item = this.items[this.tableView.indexPathForSelectedRow.row];
          segue.destinationViewController.item = item;
        } else if (segue.identifier == "showCanvas") {
          segue.destinationViewController.items = this.items;
        }
      },
      tableViewCellForRowAtIndexPath : function(tableView, indexPath) {
        //log('tableViewCellForRowAtIndexPath');
        var cell = tableView.dequeueReusableCellWithIdentifierForIndexPath("Cell", indexPath);

        var item = this.items[indexPath.row];

        var textLabel = cell.contentView.viewWithTag(1);
        textLabel.text = item["title"];

        var created = NSDate.dateWithTimeIntervalSince1970(item["created_utc"]);
        var detailTextLabel = cell.contentView.viewWithTag(2);
        detailTextLabel.text = dateFormatter.stringFromDate(created);

        var imageView = cell.contentView.viewWithTag(3);
        fetch(item["thumbnail"])
            .then(data => UIImage.imageWithData.async(UIImage, [ data ]))
            .then(image => imageView.image = image)
            .catch(error => console.error(error.toString()));

        return cell;
      },
      tableViewHeightForRowAtIndexPath : function(tableView, indexPath) {
        return 44;
      },
      loadData : function() {
        fetch("http://www.reddit.com/r/aww.json?limit=500")
            .then(data => {
              var jsonString =
                  new NSString({data : data, encoding : NSUTF8StringEncoding});
              var json = JSON.parse(jsonString.toString());
              this.items = json.data.children.map(child => child.data);

              this.tableView.reloadData();
              this.refreshControl.endRefreshing();
            })
            .catch(error => console.error(error));
      }
    },
    {
      name : "JSMasterViewController",
      exposedMethods : {
        "loadData" : {returns : interop.types.void},
        "aboutPressed:" :
            {returns : interop.types.void, params : [ UIControl ]}
      }
    });
