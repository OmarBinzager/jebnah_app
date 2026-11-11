import 'dart:convert';

class OfflinePaymentModel {
    int? id;
    String? methodName;
    String? image;
    String? imageFullPath;
    List<MethodField>? methodFields;
    String? paymentNote;
    String? instructions;
    List<MethodInformation>? methodInformations;


    OfflinePaymentModel({
        this.id,
        this.methodName,
        this.image,
        this.imageFullPath,
        this.methodFields,
        this.paymentNote,
        this.instructions,
        this.methodInformations,
    });

    OfflinePaymentModel copyWith({required String note}){
        paymentNote = note;
        return this;
    }

    factory OfflinePaymentModel.fromRawJson(String str) => OfflinePaymentModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory OfflinePaymentModel.fromJson(Map<String, dynamic> json) => OfflinePaymentModel(
        id: json["id"],
        methodName: json["method_name"],
        image: json["image"],
        imageFullPath: json["image_full_path"],
        methodFields: json["method_fields"] == null ? [] : List<MethodField>.from(json["method_fields"]!.map((x) => MethodField.fromJson(x))),
        paymentNote: json["payment_note"],
        instructions: json["instructions"],
        methodInformations: json["method_informations"] == null ? [] : List<MethodInformation>.from(json["method_informations"]!.map((x) => MethodInformation.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "method_name": methodName,
        "image": image,
        "image_full_path": imageFullPath,
        "method_fields": methodFields == null ? [] : List<dynamic>.from(methodFields!.map((x) => x.toJson())),
        "payment_note": paymentNote,
        "instructions": instructions,
        "method_informations": methodInformations == null ? [] : List<dynamic>.from(methodInformations!.map((x) => x.toJson())),
    };
}

class MethodField {
    String? fieldName;
    String? fieldData;

    MethodField({
        this.fieldName,
        this.fieldData,
    });

    factory MethodField.fromRawJson(String str) => MethodField.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MethodField.fromJson(Map<String, dynamic> json) => MethodField(
        fieldName: json["field_name"],
        fieldData: json["field_data"],
    );

    Map<String, dynamic> toJson() => {
        "field_name": fieldName,
        "field_data": fieldData,
    };
}

class MethodInformation {
    String? informationName;
    String? informationPlaceholder;
    bool? informationRequired;

    MethodInformation({
        this.informationName,
        this.informationPlaceholder,
        this.informationRequired,
    });

    factory MethodInformation.fromRawJson(String str) => MethodInformation.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MethodInformation.fromJson(Map<String, dynamic> json) => MethodInformation(
        informationName: json["information_name"],
        informationPlaceholder: json["information_placeholder"],
        informationRequired: '${json["information_required"]}'.contains('1'),
    );

    Map<String, dynamic> toJson() => {
        "information_name": informationName,
        "information_placeholder": informationPlaceholder,
        "information_required": informationRequired,
    };
}
