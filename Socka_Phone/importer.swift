import CSVImporter


func importCSV(){
    let path = "user/boocha/example.csv"
    let importer = CSVImporter<[String]>(path: path)

    importer.startImportingRecords { $0 }.onFinish { importedRecords in
        for record in importedRecords {
        print(record)    }
}
}
