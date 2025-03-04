import ballerina/sql;
import ballerinax/mysql;
import ballerina/time;
import ballerina/persist;

public client class MedicalNeedClient {
    *persist:AbstractPersistClient;

    private final string entityName = "MedicalNeed";
    private final sql:ParameterizedQuery tableName = `MedicalNeeds`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        needId: {columnName: "needId", 'type: int},
        itemId: {columnName: "itemId", 'type: int},
        beneficiaryId: {columnName: "beneficiaryId", 'type: int},
        period: {columnName: "period", 'type: time:Civil},
        urgency: {columnName: "urgency", 'type: string},
        quantity: {columnName: "quantity", 'type: int}
    };
    private string[] keyFields = ["needId", "itemId"];

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata);
    }

    remote function create(MedicalNeed value) returns MedicalNeed|persist:Error {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);
        return value;
    }

    remote function readByKey(record {|int itemId; int needId;|} key) returns MedicalNeed|persist:Error {
        return <MedicalNeed>check self.persistClient.runReadByKeyQuery(MedicalNeed, key);
    }

    remote function read() returns stream<MedicalNeed, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(MedicalNeed);
        if result is persist:Error {
            return new stream<MedicalNeed, persist:Error?>(new MedicalNeedStream((), result));
        } else {
            return new stream<MedicalNeed, persist:Error?>(new MedicalNeedStream(result));
        }
    }

    remote function update(MedicalNeed value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
    }

    remote function delete(MedicalNeed value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(MedicalNeed medicalNeed) returns boolean|persist:Error {
        MedicalNeed|persist:Error result = self->readByKey({itemId: medicalNeed.itemId, needId: medicalNeed.needId});
        if result is MedicalNeed {
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

public class MedicalNeedStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|MedicalNeed value;|}|persist:Error? {
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
                record {|MedicalNeed value;|} nextRecord = {value: <MedicalNeed>streamValue.value};
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

