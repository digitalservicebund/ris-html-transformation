package de.bund.digitalservice.ris.html.exception;

public class FileTransformationException extends RuntimeException {

  public FileTransformationException(String message) {
    super(message);
  }

  public FileTransformationException(String message, Throwable cause) {
    super(message, cause);
  }
}
