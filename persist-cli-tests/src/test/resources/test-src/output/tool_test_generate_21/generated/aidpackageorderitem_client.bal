import ballerina/sql;
import ballerinax/mysql;
import ballerina/time;
import ballerina/persist;

public client class AidPackageOrderItemClient {
    *persist:AbstractPersistClient;

    private final string entityName = "AidPackageOrderItem";
    private final sql:ParameterizedQuery tableName = `AidPackageOrderItem`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        id: {columnName: "id", 'type: int, autoGenerated: true},
        "medicalNeed.needId": {columnName: "needId", 'type: int, relation: {entityName: "medicalNeed", refTable: "MedicalNeed", refField: "needId"}},
        "medicalNeed.beneficiaryId": {'type: int, relation: {entityName: "medicalNeed", refTable: "MedicalNeed", refField: "beneficiaryId"}},
        "medicalNeed.period": {'type: time:Civil, relation: {entityName: "medicalNeed", refTable: "MedicalNeed", refField: "period"}},
        "medicalNeed.urgency": {'type: string, relation: {entityName: "medicalNeed", refTable: "MedicalNeed", refField: "urgency"}},
        "medicalNeed.quantity": {'type: int, relation: {entityName: "medicalNeed", refTable: "MedicalNeed", refField: "quantity"}},
        quantity: {columnName: "quantity", 'type: int},
        totalAmount: {columnName: "totalAmount", 'type: int}
    };
    private string[] keyFields = ["id"];

    private final map<persist:JoinMetadata> joinMetadata = {medicalNeed: {entity: MedicalNeed, fieldName: "medicalNeed", refTable: "MedicalNeed", refFields: ["needId"], joinColumns: ["needId"]}};

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata, self.joinMetadata);
    }

    remote function create(AidPackageOrderItem value) returns AidPackageOrderItem|persist:Error {
        if value.medicalNeed is MedicalNeed {
            MedicalNeedClient medicalNeedClient = check new MedicalNeedClient();
            boolean exists = check medicalNeedClient->exists(<MedicalNeed>value.medicalNeed);
            if !exists {
                value.medicalNeed = check medicalNeedClient->create(<MedicalNeed>value.medicalNeed);
            }
        }
        _ = check self.persistClient.runInsertQuery(value);
        return value;
    }

    remote function readByKey(int key, AidPackageOrderItemRelations[] include = []) returns AidPackageOrderItem|persist:Error {
        return <AidPackageOrderItem>check self.persistClient.runReadByKeyQuery(AidPackageOrderItem, key, include);
    }

    remote function read(AidPackageOrderItemRelations[] include = []) returns stream<AidPackageOrderItem, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(AidPackageOrderItem, include);
        if result is persist:Error {
            return new stream<AidPackageOrderItem, persist:Error?>(new AidPackageOrderItemStream((), result));
        } else {
            return new stream<AidPackageOrderItem, persist:Error?>(new AidPackageOrderItemStream(result));
        }
    }

    remote function update(AidPackageOrderItem value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
        if value.medicalNeed is record {} {
            MedicalNeed medicalNeedEntity = <MedicalNeed>value.medicalNeed;
            MedicalNeedClient medicalNeedClient = check new MedicalNeedClient();
            check medicalNeedClient->update(medicalNeedEntity);
        }
    }

    remote function delete(AidPackageOrderItem value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(AidPackageOrderItem aidPackageOrderItem) returns boolean|persist:Error {
        AidPackageOrderItem|persist:Error result = self->readByKey(aidPackageOrderItem.id);
        if result is AidPackageOrderItem {
            return true;
        } else if result is persist:InvalidKeyError {
            return false;
        } else {
            return result;
        }
    }

    public function close() returns persist:Error? {
        return self.persistClient.close();
    }
}

public enum AidPackageOrderItemRelations {
    MedicalNeedEntity = "medicalNeed"
}

public class AidPackageOrderItemStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|AidPackageOrderItem value;|}|persist:Error? {
        if self.err is persist:Error {
            return <persist:Error>self.err;
        } else if self.anydataStream is stream<anydata, sql:Error?> {
            var anydataStream = <stream<anydata, sql:Error?>>self.anydataStream;
            var streamValue = anydataStream.next();
            if streamValue is () {
                return streamValue;
            } else if (streamValue is sql:Error) {
                return <persist:Error>error(streamValue.message());
            } else {
                record {|AidPackageOrderItem value;|} nextRecord = {value: <AidPackageOrderItem>streamValue.value};
                return nextRecord;
            }
        } else {
            return ();
        }
    }

    public isolated function close() returns persist:Error? {
        if self.anydataStream is stream<anydata, sql:Error?> {
            var anydataStream = <stream<anydata, sql:Error?>>self.anydataStream;
            sql:Error? e = anydataStream.close();
            if e is sql:Error {
                return <persist:Error>error(e.message());
            }
        }
    }
}

