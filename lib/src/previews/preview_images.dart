import 'dart:convert';
import 'dart:typed_data';

import '../attachments/model/mre_pasted_image.dart';

/// Small gradient images for previews, so a card shows attachments without a
/// clipboard.
final List<MREPastedImage> mrePreviewImages = [
  MREPastedImage(
    bytes: Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAACRklEQVR42tXOhVIaAAAG4H91y1ve6pa3vOWtbnnLW93ylrc8jBk4c6SASCoIAoKgIKgIBiAICAbqenNdT7Tn+L8n+ACBaIZANDNPPCtfPLtAMqdQMveFdF6RbH6xbEGJfGGpfJGwdrFQsaRMsfSlclm5cnmFakWlamVV3apq9eoa9ZpX9WtF9etEmvVi7QaJdqNUt0mm2yzXb6k1bFUYtimN21XGHXUNO9UNu9SNu+tNezSmvVrzPp15v77pgMFy0Gg51GA93Gg9Ymo+arIdM9uON9lPWOwnrY5TzY7TtpYzdudZh/Nci+u803XB1XrR5b7U6r7s9lzxeK62tV1rbwf1/rq3HdT7Gz4vqPc3O7yg3t/y+0C9vx3wgXp/J9AB6v3dTj+o9/e6/KDe3+8OgHr/IBgA9f5hTyeo949CXaDePw53gXr/pLcb1Punfd2g3j/rD4J6/3wgCOq9YKAH1Pu8SAjU+/xoCNT7glgY1PvCwTCo90XxXlDvixN9oN6XDPWBel+a7Af1XpjqB/W+LD0A6n15OgLqfcVwBNT7ykwU1PuqbBTU++qRGKj3NaMxUO9FY4Og3ovH46DeS3JxUO+lEwlQ72WTCVDv5VNDoN4rppKg3itfJ0G9V71JgXpf9zYF6r36XRrUe837YVDvtR+GQb3XfcyAeq//lAH13vA5C+q9cToL6n3j9Aio96Yvo6Dem7+Ognrf9G0M1HvL9zFQ760/xkG9t/3MgXpv/5UD9d7xewLU+5Y/E6DeO/9Ognrf+m/qP2OmkZ1t7ZPaAAAAAElFTkSuQmCC',
      ),
    ),
    mimeType: 'image/png',
  ),
  MREPastedImage(
    bytes: Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAACI0lEQVR42tXOiaoMYBgG4BchhBCyhBBCCFlCCCGELCGEELKEEEIIWUIImTlz5syZs+/7mbPv+766he/7/t81uI73uYIH/wLwgRE+MNIHR/ngaB83xseN9aFxPjTex0/w8RN9eJIPT/YJU3zCVB+Z5iPTfeIMnzjTR2f56GyfNMcnzfXJ83zyfJ+ywKUsdKmLXOpil7bEpS116ctc+nKXvsJlrHQZq1zmape5xmWtdVnrXPZ6l73B5Wx0OZtc7maXu8XlbXV521z+dpe/wxXstIJdVrjbCvdY0V4r2mfF+634gJUctJJDVnrYSo9Y7KjFjnHvLXYc1HsrOwHqvZWdBPXeyk+Bem/lp0G9t4ozoN5bxVlQ763yHKj3Vnke1HurugDqvVVdBPXeqi+Beq/Vl0G915oroN5rzVVQ77X2Gqj3Wnsd1HutuwHqvdbdBPVe62+Beq/1t0G914Y7oN5rw11Q77XxHqj32ngf1HttegDqvTY9BPVemx+Beq/Nj0G915YnoN5ry1NQ77XlGaj32voc1HttfQHqvba9BPVe216Beq/tr0G9l/Y3oN5Lx1tQ76XjHaj30vke1Hvp/ADqvXR9BPVeuj6Bei/dn0G9l+4voN5Lz1dQ76XnG6j30vsd1Hvp/QHqvfT9BPVe+n6Bei/9v0G9l/4/oN7LQADUexkIgnovgyFQ72UwHtR7GQqDei9DEVDvZTgR1HsZjoJ6L3+T/wNy1mn1fm5VrgAAAABJRU5ErkJggg==',
      ),
    ),
    mimeType: 'image/png',
  ),
  MREPastedImage(
    bytes: Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAACW0lEQVR42tXOiTIUAAAG4P8ZOqaajsGgKJIkisJgUBRJEkVhMCiKJImiMBgU5UgSRbF21y5LS+4rSSSJJJEkkkSS6jn+7wk+CBSWCRSXlyitKFFeKVRZJVJdLdq0Rqy2tlR9XemW9RKNDVJNBamWYtk2pXJt5XIdFdkOVZnuxgo9tUp99cpdm58YaMgNNeV7tlYZaVUba1ebbH9qqlNjpltjvrPWQq/WUr/Oanf9foN6a8MGm72NB40abY2b7Eya7U2bD5u1OJi3Olq0HrVsc7Jqc973zMW6/bhNu+uB5262HSftOtwPvfCw7/R06PQ68tLbscvHqcv3WLefc7e/y6szJ3oCXHsC3V6fOwXqfW+QO6j3vcEeoN6/CfEE9b7vgheo932h3qDevw3zAfW+/5IvqPf94X6g3g9E+IN6PxB5GtT7d1cCQL0fjAoE9X4w+iyo9++vBYF6PxQTDOr9UOx5UO8/xIWAej8cHwrq/XDCRVDvPyaGgXo/khQO6v1I8mVQ70dTIkC9H70ZCer9p9SroN6PpUWBej92OxrU+8/p10G9H8+IAfV+PCsW1Psvd+JAvZ/Ijgf1fiInAdT7r/cSQb2fzE0C9X4yLxnU+6n8FFDvpx7cAPX+W0EqqPfThWmg3k8/ugXq/feidFDvZ4ozQL2fEWSCev9DmAXq/awoG9T7WfFdUO9/SnJAvZ+T5oJ6P1d2H9T7eVkeqPfzFfmg3v+qfAjq/YK8ANT7hapCUO9/Vz8G9X6xpgjU+8XaYlDv/9QJQL1fahCCer/UKAL1/m+TGNT7fy2S//ZPxehnm8O2AAAAAElFTkSuQmCC',
      ),
    ),
    mimeType: 'image/png',
  ),
];
