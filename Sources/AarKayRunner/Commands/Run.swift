import AarKayRunnerKit
import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `run` subcommand.
struct RunCommand: CommandProtocol {
    struct Options: OptionsProtocol {
        let global: Bool
        let verbose: Bool
        let force: Bool
        let dryrun: Bool

        public static func evaluate(
            _ mode: CommandMode
        ) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
                <*> mode <| Switch(flag: "v", key: "verbose", usage: "Adds verbose logging.")
                <*> mode <| Switch(flag: "f", key: "force", usage: "Will not check if the directory has any uncomitted changes.")
                <*> mode <| Switch(flag: "n", key: "dryrun", usage: "Will only create files and will not write them to disk.")
        }
    }

    var verb: String = "run"
    var function: String = "Generate respective files from the datafiles inside AarKayData."

    func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Run>
        var runnerUrl = AarKayPaths.default.runnerPath()
        var cliUrl: URL = AarKayPaths.default.cliPath()

        if !FileManager.default.fileExists(atPath: runnerUrl.path) || options.global {
            runnerUrl = AarKayPaths.default.runnerPath(global: true)
            cliUrl = AarKayPaths.default.cliPath(global: true)
        }

        guard FileManager.default.fileExists(atPath: runnerUrl.path),
            FileManager.default.fileExists(atPath: cliUrl.path) else {
            return .failure(
                AarKayError.missingProject(url: runnerUrl.deletingLastPathComponent())
            )
        }

        var arguments: [String] = []
        if options.verbose { arguments.append("--verbose") }
        if options.force { arguments.append("--force") }
        if options.dryrun { arguments.append("--dryrun") }
        return Tasks.execute(at: cliUrl.path, arguments: arguments)
        /// </aarkay>
    }
}
