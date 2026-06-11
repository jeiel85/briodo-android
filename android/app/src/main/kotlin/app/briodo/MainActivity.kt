package app.briodo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.briodo/ondevice_llm"
    private var llmInference: LlmInference? = null
    private var currentModelPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initModel" -> {
                    val modelPath = call.argument<String>("modelPath")
                    if (modelPath == null) {
                        result.error("INVALID_ARGUMENT", "Model path is null", null)
                        return@setMethodCallHandler
                    }
                    try {
                        if (currentModelPath == modelPath && llmInference != null) {
                            result.success(true)
                            return@setMethodCallHandler
                        }
                        llmInference?.close()
                        val file = File(modelPath)
                        if (!file.exists()) {
                            result.error("FILE_NOT_FOUND", "Model file does not exist at $modelPath", null)
                            return@setMethodCallHandler
                        }
                        val options = LlmInference.LlmInferenceOptions.builder()
                            .setModelPath(modelPath)
                            .setTemperature(0.2f)
                            .build()
                        llmInference = LlmInference.createFromOptions(applicationContext, options)
                        currentModelPath = modelPath
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_FAILED", "Failed to initialize model: ${e.message}", e.stackTraceToString())
                    }
                }
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt == null) {
                        result.error("INVALID_ARGUMENT", "Prompt is null", null)
                        return@setMethodCallHandler
                    }
                    val currentLlm = llmInference
                    if (currentLlm == null) {
                        result.error("NOT_INITIALIZED", "Model is not initialized", null)
                        return@setMethodCallHandler
                    }
                    thread {
                        try {
                            val response = currentLlm.generateResponse(prompt)
                            runOnUiThread {
                                result.success(response)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("INFERENCE_FAILED", "Inference failed: ${e.message}", e.stackTraceToString())
                            }
                        }
                    }
                }
                "closeModel" -> {
                    llmInference?.close()
                    llmInference = null
                    currentModelPath = null
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
