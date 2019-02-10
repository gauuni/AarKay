import Foundation

/// A type encapsulating all errors related to `AarKayKit`.
///
/// - unknownError: Returned when the program reaches an unexpected state.
/// - missingFileName: Returned when there is no file name.
/// - modelDecodingFailure: Returned when the data could not be serialized to the Template.
/// - templateNotFound: Returned when the template could not be found.
/// - multipleTemplatesFound: Returned when multiple templates exist under same name.
/// - invalidTemplate: Returned when the name of template doesn't conform to AarKayTemplate.
public enum AarKayKitError: Error {
    case unknownError(error: Error?)
    case invalidContents(InvalidContentsReason)
    case invalidTemplate(InvalidTemplateReason)

    /// The underlying reason the invalid contents error occurred.
    ///
    /// - objectExpected: Returned when object is expected to decode single.
    /// - arrayExpected: Returned when array is expected to decode collection.
    /// - invalidModel: Returned when the data doesn't match the requirements of template.
    /// - missingFileName: Returned when there is no filename for generatedfile.
    public enum InvalidContentsReason {
        case objectExpected
        case arrayExpected
        case invalidModel(
            fileName: String,
            template: String,
            type: String,
            context: [String: Any]
        )
        case invalidPluginModel(
            plugin: String,
            type: String,
            context: [String: Any]
        )
        case missingFileName
    }

    /// The underlying reason the invalid templates error occurred.
    ///
    /// - templatesNil: Returned when there are no templates for the plugin.
    /// - mutipleFound: Returned when there are more than one template with the same name.
    /// - notFound: Returned when there is no template with that name.
    /// - invalidName: Returned when the template name is invalid.
    public enum InvalidTemplateReason {
        case templatesNil(name: String)
        case mutipleFound(name: String)
        case notFound(name: String)
        case invalidName(name: String)
    }
}

extension AarKayKitError {
    public static func internalError(
        _ message: String,
        with error: Error? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AarKayKitError {
        /// <aarkay internalError>
        assertionFailure("\(file):\(line) - \(message). \(error.debugDescription)")
        /// </aarkay>
        return AarKayKitError.unknownError(error: error)
    }
}

// MARK: - LocalizedError

extension AarKayKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            var desc = "An unknown error occurred."
            if let err = error {
                desc = desc + "- " + err.localizedDescription
            }
            return desc
        case .invalidContents(let reason):
            return reason.localizedDescription
        case .invalidTemplate(let reason):
            return reason.localizedDescription
        }
    }
}

extension AarKayKitError.InvalidContentsReason: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .arrayExpected:
            return "Collection datafile expect an array as an input."
        case .objectExpected:
            return "Single datafile expects an object as an input."
        case .invalidModel(let fileName, let template, let type, let context):
            return "The data for fileName - (\(fileName)) and template (\(template)) could not be serailzied to type - (\(type))\nContext :- \(context)"
        case .invalidPluginModel(let plugin, let type, let context):
            return "The data for plugin - (\(plugin)) could not be serailzied to type - (\(type))\nContext :- \(context)"
        case .missingFileName:
            return "Failed to resolve filename."
        }
    }
}

extension AarKayKitError.InvalidTemplateReason: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .templatesNil(let plugin):
            return "Failed to find templates for plugin - \(plugin)"
        case .mutipleFound(let name):
            return "Mutliple templates found with name - \(name)"
        case .notFound(let name):
            return "Failed to find the template with name - \(name)"
        case .invalidName(let name):
            return "Failed to resolve template with name - \(name)"
        }
    }
}
