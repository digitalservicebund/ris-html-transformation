package de.bund.digitalservice.ris.html.exception;

public class XMLElementNotFoundException extends RuntimeException {
  public XMLElementNotFoundException(String message) {
    super(message);
  }

  public XMLElementNotFoundException(String message, Throwable cause) {
    super(message, cause);
  }
}
